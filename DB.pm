package Jorge::DB;

use DBI;

use Jorge::Config;
use strict;

my $c = new Jorge::Config;

sub new {
	my $class = shift;
	my $struct = {
		_dbh => DBI->connect(
						'dbi:mysql:database=' . $c->db_name . ';host=' . $c->db_host . ';port=3306',
						$c->db_user,
						$c->db_password
					)
	};
	my $self = bless $struct, $class;
	return $self;
}

sub get_dbh {
	my $self = shift;
	return $self->{_dbh};
}

sub execute {
	my $self = shift;
	my $db_query = shift;

	my @params = @_;

	my $dbh = $self->get_dbh;
	my $sth = $dbh->prepare($db_query);
	
	if ($sth->execute(@params)) {
		return $sth;
	} else {
		print STDERR $dbh->{err};
		return 0;
	}
}

sub prepare {
	my $self = shift;
	my $query = shift;
	my $dbh = $self->get_dbh;

	return $dbh->prepare($query);
}

sub get_last_insert_id {
	my $self = shift;
	my $dbh = $self->get_dbh;
	return $dbh->{'mysql_insertid'};
}

sub execute_prepared {
	my $self = shift;
	my $sth = shift;

	my @params = @_;
	$sth->execute(@params);
	if ($self->{_dbh}->errstr) {
		warn '***ERROR: ' . $self->{_dbh}->errstr . ' : ' .  $sth->{Statement};
	}

	return $sth;
}

sub errstr
{
	my $self = shift;

	return $self->{_dbh}->errstr;
}

1;
