package Jorge::DBEntity;

use Date::Manip;
use Data::Dumper;
use Jorge::DB;
use strict;

my $db;

sub new {
	my $class = shift;
	my $obj = bless {}, $class;
	return $obj;
}

sub _db {
	unless ($db) {
		$db = new Jorge::DB;
	};
	return $db;
}

sub _load {
	my $self = shift;
	my $row = shift;

	my @fields = @{$self->_fields->[0]};
	my %fields = %{$self->_fields->[1]};

	for (keys %$row) {
		unless ($fields{$_}->{class}) {
			$self->{$_} = $row->{$_};
			next;
		}

		my $obj = $fields{$_}->{class};
		$obj->get_from_db($row->{$_});
		$self->{$_} = $obj;
	}
}

sub _pk {
	my $self = shift;
	my @pk;

	my @fields = @{$self->_fields->[0]};
	my %fields = %{$self->_fields->[1]};

	for (@fields) {
		next unless $fields{$_}->{pk};
		push @pk, $_;
	}

	return \@pk;
}

sub _params {
	my $self = shift;
	my $not_nulls = shift;

	my @params;

	my @fields = @{$self->_fields->[0]};
	my %fields = %{$self->_fields->[1]};

	for (@fields) {
		next if $fields{$_}->{pk};
                next if $fields{$_}->{timestamp};
		next if $not_nulls && !$self->{$_};

		if ($fields{$_}->{datetime}) {
			push @params, UnixDate($self->{$_}, '%Y-%m-%d %H:%M:%S');
			next;
		}

		unless ($fields{$_}->{class}) {
			push @params, $self->{$_};
			next;
		}

		push @params, $self->{$_}->{$self->{$_}->_pk->[0]};
	}

	return @params;
}

sub get_from_db {
	my $self = shift;
	my $id = shift;

	return 0 unless $id;

	my @fields = @{$self->_fields->[0]};
	my %fields = %{$self->_fields->[1]};
	my $table_name = $self->_fields->[2];

	my @pk = grep { $fields{$_}->{pk} } keys %fields;

	my $query = 'SELECT ';
	$query .= join(',', @fields);
	$query .= ' FROM ' . $table_name . ' WHERE ' . $pk[0] . ' = ' . $id;

	my $sth;
	unless ($sth = $self->_db->execute($query)) { return 0 }
	$self->_load($sth->fetchrow_hashref);

	return $self->{$pk[0]};
}

sub insert {
	my $self = shift;

	my @fields = @{$self->_fields->[0]};
	my %fields = %{$self->_fields->[1]};
	my $table_name = $self->_fields->[2];

	$self->before_insert();
	$self->before_save();

	my $query = 'INSERT INTO ' . $table_name;
	$query .= ' (' . join(',', grep { !$fields{$_}->{pk} && !$fields{$_}->{timestamp} && $self->{$_} } @fields) . ')';
	$query .= ' VALUES (' . join(',', map { '?' } $self->_params(1)) . ')';
	if ($self->_db->execute($query, $self->_params(1))) {
		$self->get_from_db($self->_db->get_last_insert_id);
		return $self->{$self->_pk->[0]};
	} else {
		return 0;
	}
}

sub update {
	my $self = shift;

	my @fields = @{$self->_fields->[0]};
	my %fields = %{$self->_fields->[1]};
	my $table_name = $self->_fields->[2];

	my @pk = grep { $fields{$_}->{pk} } keys %fields;

	$self->before_update();
	$self->before_save();

	my $query = 'UPDATE ' . $table_name;
	$query .= ' SET ';
	$query .= join(',', map { $_ . ' = ?' } grep { !$fields{$_}->{pk} && !$fields{$_}->{timestamp} } @fields);
	$query .= ' WHERE ' . $pk[0] . ' = ?';
	if ($self->_db->execute($query, $self->_params, $self->{$pk[0]})) {
		return $self->{$pk[0]};
	} else {
		return 0;
	}
}

sub delete {
	my $self = shift;

	my @fields = @{$self->_fields->[0]};
	my %fields = %{$self->_fields->[1]};
	my $table_name = $self->_fields->[2];

	my @pk = grep { $fields{$_}->{pk} } keys %fields;

	$self->before_delete();

	my $query = 'DELETE FROM ' . $table_name;
	$query .= ' WHERE ' . $pk[0] . ' = ?';
	if ($self->_db->execute($query,  $self->{$pk[0]})) {
		return 1;
	} else {
		return 0;
	}
}


sub AUTOLOAD {
	our $AUTOLOAD;
	return if $AUTOLOAD =~ /::DESTROY$/;

	my ($self, $value) = @_;
	die "not an object" unless ref($self);

	my $field = [split(/::/,$AUTOLOAD)]->[-1];

	my @fields = @{$self->_fields->[0]};
	my %fields = %{$self->_fields->[1]};

	die "method \"$field\" doesn't exist" unless grep { $_ eq $field } @fields;

	if ($fields{$field}->{read_only}) { return $self->{$field} }

	return $self->{$field} unless defined $value;

	for ($value) {

		if ($fields{$field}->{values}) {
			last unless grep { $_ eq $value } @{$fields{$field}->{values}};
		}

		if ($fields{$field}->{class}) {
			last unless ref($value) eq ref($fields{$field}->{class});
		}

		$self->{$field} = $value;
	}

	return $self->{$field};
}

sub before_insert{
	my $self = shift;
	return 1;
}


sub before_update{
	my $self = shift;
	return 1;
}

sub before_save{
	my $self = shift;
	return 1;
}

sub before_delete{
	my $self = shift;
	return 1;
}

1;
