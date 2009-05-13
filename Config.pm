package Jorge::Config;

use Config::YAML;
use strict;

my $c;

sub new {
	my $class = shift;
	my $obj = bless {}, $class;
	-e ('config/config.yml') || die 'config file not found on config/config.yml';
	$c = Config::YAML->new(config => 'config/config.yml');
	return $obj;
}

sub db_host { return $c->{database}->{host} }
sub db_name { return $c->{database}->{db} }
sub db_user { return $c->{database}->{user} }
sub db_password { return $c->{database}->{password} }

1;
