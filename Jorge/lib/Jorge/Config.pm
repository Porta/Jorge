package Jorge::Config;

use Config::YAML;
use warnings;
use strict;

=head1 NAME

Jorge::Config - Configuration package to interface with Config::YAML file

=head1 VERSION

Version 0.01

=cut

our $VERSION     = '0.01';
our $CONFIG_FILE = 'config/jorge.yml';

sub new {
    my $class = shift;
    my $obj = bless {}, $class;
    -e ($CONFIG_FILE) || die 'config file not found on ' . $CONFIG_FILE;
    my $c;
    $c = Config::YAML->new( config => $CONFIG_FILE );
    return $c;
}

=head1 SYNOPSIS

It is not expected accessing to this package directly. So, move to main
Jorge docs for reference.


=head1 AUTHORS

Mondongo, C<< <mondongo at gmail.com> >> Did the important job and started 
this beauty.

Julian Porta, C<< <julian.porta at gmail.com> >> took the code and tried 
to make it harder, better, faster, stronger.

=head1 BUGS

Please report any bugs or feature requests to C<bug-jorge at rt.cpan.org>,
or through the web interface at 
 L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Jorge>.  
I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Jorge


You can also look for information at:

=over 4

=item * Github Project Page

L<http://github.com/Porta/Jorge/tree/master>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Jorge>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Jorge>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Jorge>

=item * Search CPAN

L<http://search.cpan.org/dist/Jorge/>

=back


=head1 ACKNOWLEDGEMENTS

Mondongo C<< <mondongo at gmail.com> >> For starting this.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Julian Porta, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;    # End of Jorge::Config

