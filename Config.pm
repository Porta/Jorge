package Jorge::Config;

use Config::YAML;
use strict;

our $CONFIG_FILE = 'config/jorge.yml';

sub new {
    my $class = shift;
    my $obj = bless {}, $class;
    -e ($CONFIG_FILE) || die 'config file not found on ' . $CONFIG_FILE;
    my $c;
    $c = Config::YAML->new(config => $CONFIG_FILE);
    return $c;
}

1;
