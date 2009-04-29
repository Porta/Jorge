package Jorge::Utils;

use Data::Dumper;
use Time::Duration;
use Date::Manip;
use strict;

sub new {
	my $class = shift;
	my $obj = bless {}, $class;
	return $obj;
}

sub sendMail {
	my $self = shift;
	my ($from, $from_name, $to, $bcc, $subject, $body, $content_type) = @_;
	$from ||= "from";
	$from_name ||= "from";
	$to ||= "to";
	$bcc ||= "bcc";
	$subject ||= "subject";
	$body ||= "body";
	$content_type ||= "text/plain";
		
		open SENDMAIL, '|/usr/sbin/sendmail -t';
		print SENDMAIL << "MAIL";
From: $from ($from_name)
To: $to
Bcc: $bcc
Subject: $subject
Content-Type: $content_type

$body
MAIL
		close SENDMAIL;
}

sub when {
	# my $self = shift;
	# my $t = shift;
	# my $when = ParseDate($t);
	# my $time = DateCalc( now , "$when");
	# my $secs = &UnixDate($time,"%s");
	# my $precision = shift || 1;
	# return ago($secs,$precision);
	#return $secs;
}


sub random {
	#Thanks, Iaco.
	my $self = shift;
	#receive number of chars for the random string
	my $c = shift || 6;
	my @chars = ( "A" .. "Z", "a" .. "z", 0 .. 9, qw(! @ $ % ^ & *) );
	my $password = join("", @chars[ map { rand @chars } ( 1 .. $c ) ]);
	return $password;
}

sub sanitize {
	my $self = shift;
	my $message = shift;
	my $forbidden_words = join('|', qw(script javascript object embed frameset iframe frame applet style));
	my $regexp = 
		'<\s*(' . 
			$forbidden_words . 
		').*?>.*?</(' . 
			$forbidden_words 
		. ')>';
	$regexp = qr/$regexp/;
	$message =~ s/$regexp//gsi;
	#strip HTML tags except (<b><i>)
	$message =~ s[<(?!(/?b>|/?i>)).*?>][]gsi;
	return $message;
}

1;