package Jorge::Extended;
use base 'Jorge::DBEntity';

#Helper class to extend DBEntity.pm
use Data::Dumper;
use Digest::MD5;
use strict;

sub get_by {
	my ($self,@params) = @_;

	return 0 unless @params;

	my $table_name = $self->_fields->[2];
	my %fields = %{$self->_fields->[1]};

	my @cols;
	my @vals;

	foreach my $col (@params) {
		push(@cols, "$col = ?");
		my $v;
		#Porta
		#Allows to use a object as a param for get_by method
		if ($fields{$col}->{class}) {
			my $p = $self->{$col}->_pk;
			my $o = $self->{$col};
			$v = $o->{$$p[0]};
		}else{
			$v = $self->{$col};
			}
		push(@vals, $v);
	}

	my $columns = join(' AND ', @cols);
	my $query = "SELECT * FROM $table_name WHERE ($columns)";
	#warn ($query, @vals);
	my $return = $self->_db->prepare($query);
	my $sth = $self->_db->execute_prepared($return,@vals);

	$self->_load($sth->fetchrow_hashref);

	return $self;
}

sub encodeMd5 {
	my $self = shift;
	my @params = @_;

	my $md5 = Digest::MD5->new;

	foreach my $key (@params){
		my $k = $self->{$key};
		$md5->add($k);
	}

#	if ($params{Lenght}){
#		return substr($md5->hexdigest,0,$params{Lenght});
#	}else{
		return substr($md5->hexdigest,0,8);
#	}
}

;1