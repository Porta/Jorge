package Jorge::ObjectCollection;

use strict;

sub new {
    my $class = shift;
    return bless [], $class;
}

sub get_next {
    my $self = shift;

    my $value = shift @$self;
    return 0 unless $value;

    my $obj = $self->create_object;
    if ( $obj->get_from_db($value) ) { return $obj }

    return 0;
}

sub _create_query {
	my $self = shift;
	my $params = shift;

	my $page = $params->{_page} || 0;
	my $pagelength = $params->{_entries_per_page} || 0;

	my $obj = $self->create_object;

	my @fields = @{$obj->_fields->[0]};
	my %fields = %{$obj->_fields->[1]};
	my $table_name = $obj->_fields->[2];

	my @pk = grep { $fields{$_}->{pk} } keys %fields;

	my $query = 'SELECT ' . $pk[0] . ' FROM ' . $table_name;
	my @query_params;

	for my $key (keys %$params) {
		next if $key =~ /^_/;
		next unless grep { $_ eq $key } @fields;

		my ($value, $oper);
		if (ref($params->{$key}) eq 'ARRAY') {
			$oper = $params->{$key}->[0];
			#Porta.
			#Enable use a object as a parameter to search for 
			if ($fields{$key}->{class} && ref($params->{$key}->[1]) eq ref($fields{$key}->{class})){
				my $p = $params->{$key}->[1]->_pk;
				my $o = $params->{$key}->[1];
				$value = $o->{$$p[0]};
			}else{
				$value = $params->{$key}->[1];
			}

			#Porta
			#added OR support.
			#$params{'User'} = [ 'or',[ [$oper,$user1],[$oper,$user2],[$oper,$user3] ] ];
			if (lc($oper) eq 'or') {
				my $values = $value;
				my $or;
				my @p;
				foreach my $v (@{$values}){
					$or .= " $key $$v[0] ? OR";
					
					# $user1, $user2, $user3 might be objects, so we check that
					# of course, the attribute has to be an object, too
					if ($fields{$key}->{class} && ref($$v[1]) eq ref($fields{$key}->{class})){
						my $p = $$v[1]->_pk;
						my $o = $$v[1];
						push(@p, $o->{$$p[0]});
					} else {
						push(@p,$$v[1]);
					}
					
				}
				$or =~ s/(.*) OR/$1/;
				next unless $or;
				if (@query_params) {
					$query .= " AND ($or)";
				}else{
					$query .= " WHERE ($or)";
				}
				push (@query_params, @p);
				next;
			}
			if (lc($oper) eq 'in') {my $str = '?' x $value;
    			#IN expects an array in $value
			    my $str = join(",",map{'?'} @$value);
				if (@query_params) {
					$query .= " AND $key IN ($str)";
				} else {
					$query .= " WHERE $key IN ($str)";
				}
			    push (@query_params, @$value);
				next;
			}
			#Porta.
			#Added MySql Between.
			#NOTE: Allways provide min and max values
			#$params{Count} = ['between',$q->param('mv') || '1',$q->param('Mv') || '1000000'];
			#Start MySql BETWEEN Support.
			if (lc($oper) eq 'between') {
				if (@query_params) {
					$query .= " AND $key BETWEEN ? AND ?";
				} else {
					$query .= " WHERE $key BETWEEN ? AND ?";
				}
				push @query_params, @$value;
				next;
			}
			
			#Joaquin
			#Added MySQL IS NULL support
			if (lc($oper) eq 'is null') {
				if (@query_params) {
					$query .= " AND $key IS NULL";
				} else {
					$query .= " WHERE $key IS NULL";
				}
				next;
			}
			#End MySQL IS NULL support

			unless ($oper =~ /^[<>=!]{1,2}||between||or||like$/) { $oper = '=' }
		} else {
			
			#Porta.
			#Enable use a object as a parameter to search for 
			if ($fields{$key}->{class}){
				my $p = $params->{$key}->_pk;
				my $o = $params->{$key};
				$value = $o->{$$p[0]};
			}else{
				$value = $params->{$key};
			}
			$oper = '=';
		}

		if (@query_params) {
			$query .= " AND $key $oper ?";
		} else {
			$query .= " WHERE $key $oper ?";
		}
		push @query_params, $value;
	}

	if ($params->{_order_by}) {
		if (ref($params->{_order_by}) eq 'ARRAY') {
			for my $param (@{$params->{_order_by}}) {
				my $asc;
				if ($param =~ /^\+/) {
					$asc = 1;
					substr($param,0,1) = '';
				}
				next unless grep { $_ eq $param } @fields;
				if ($query !~ /ORDER BY/) {
					$query .= " ORDER BY $param" . ($asc ? ' ASC': ' DESC');
				} else {
					$query .= ", $param" . ($asc ? ' ASC': ' DESC');
				}
			}
		} else {
			my $param = $params->{_order_by};
			my $asc;
			if ($param =~ /^\+/) {
				$asc = 1;
				substr($param,0,1) = '';
			}
			if (grep { $_ eq $param } @fields) {
				$query .= ' ORDER BY ' . $param . ($asc ? ' ASC' : ' DESC');
			}
		}
	}


	if ($pagelength) {
		$query .= " LIMIT $page,$pagelength";
	}

	return ($query, \@query_params);
}

sub get_count {
	my $self = shift;
	my $params = { @_ };

    my $obj = $self->create_object;

    my ( $query, $query_params ) = $self->_create_query($params);
    $query =~ s/^SELECT .+? FROM/SELECT COUNT(*) AS q FROM/;

    my $sth;
    $sth = $obj->_db->execute( $query, @$query_params );
    my $row = $sth->fetchrow_hashref;

    return $row->{q};
}

sub get_all {
    my $self   = shift;
    my $params = {@_};

    my ( $query, $query_params );
    if ( $params->{_query} ) {
        ( $query, $query_params ) =
          ( $params->{_query}, $params->{_query_params} );
    }
    else {
        ( $query, $query_params ) = $self->_create_query($params);
    }

    if ( $params->{_order_by} ) {
        if ( ref( $params->{_order_by} ) eq 'ARRAY' ) {
            for my $param ( @{ $params->{_order_by} } ) {
                my $asc;
                if ( $param =~ /^\+/ ) {
                    $asc = 1;
                    substr( $param, 0, 1 ) = '';
                }
                next unless grep { $_ eq $param } @fields;
                if ( $query !~ /ORDER BY/ ) {
                    $query .= " ORDER BY $param" . ( $asc ? ' ASC' : ' DESC' );
                }
                else {
                    $query .= ", $param" . ( $asc ? ' ASC' : ' DESC' );
                }
            }
        }
        else {
            my $param = $params->{_order_by};
            my $asc;
            if ( $param =~ /^\+/ ) {
                $asc = 1;
                substr( $param, 0, 1 ) = '';
            }
            if ( grep { $_ eq $param } @fields ) {
                $query .= ' ORDER BY ' . $param . ( $asc ? ' ASC' : ' DESC' );
            }
        }
    }

    return scalar @$self;
}

1;



