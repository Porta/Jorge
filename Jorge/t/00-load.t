#!perl -T

use Test::More tests => 5;

BEGIN {
	use_ok( 'Jorge' );
	use_ok( 'Jorge::DB' );
	use_ok( 'Jorge::DBEntity' );
	use_ok( 'Jorge::ObjectCollection' );
	use_ok( 'Jorge::Config' );
}

diag( "Testing Jorge $Jorge::VERSION, Perl $], $^X" );
