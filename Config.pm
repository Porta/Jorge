package Jorge::Config;

use Config::YAML;
use strict;

my $c;

sub new {
	my $class = shift;
	my $obj = bless {}, $class;
	$c = Config::YAML->new(config => 'config/config.yml');
	return $obj;
}

sub base_url { return $c->{general}->{base_url} }
sub pagelength { return $c->{general}->{pagelength} }
sub site_path { return $c->{general}->{site_path} }
sub tmpl_path { return $c->{general}->{templates_dir} }
sub image_path { return $c->{general}->{image_path} }
sub page_directory { return $c->{general}->{page_directory} }
sub image_size { return $c->{general}->{image_size} }

sub db_host { return $c->{database}->{host} }
sub db_name { return $c->{database}->{db} }
sub db_user { return $c->{database}->{user} }
sub db_password { return $c->{database}->{password} }

1;