package Jorge::RemoteCollection;
use strict;

use Data::Dumper;
use JSON;
use LWP::UserAgent;

my $json = JSON->new();
my $ua = LWP::UserAgent->new;

sub new {
	my $class = shift;
	return bless {}, $class;
}

sub get_next {
	my $self = shift;

	my $array = $self->{array};
	my $row = pop(@$array);

	if ($row){
		bless $row, $self->{isa};
	}else{
		return 0;
	}

	return $row;
}

sub get_count {
	my $self = shift;
	my %parameters = @_;
	
	# $json_params{field} = ["oper",value];
	my $json_params = $parameters{Parameters} || return 0 unless ref($parameters{Parameters}) eq 'HASH';
	my $object = $parameters{Object} || return 0;
	my $url = $parameters{Url} || return 0;
	

	my %params;
	$params{'object'} = $object;
	$params{'parameters'} = $json_params;

	my $response = $ua->post($url . "/remote/advanced", \%params);
	
	if ($response->is_success) {
		return $response->decoded_content;
	}else{
		return $response->status_line;
	}
}

sub get_all {
	my $self = shift;
	my %parameters = @_;
	
	my $object = $parameters{Object} || return 0;
	my $url = $parameters{Url} || return 0;

	my %params;
	$params{'object'} = $object;
	$params{'parameters'} = '';

	my $response = $ua->post($url . "/remote/post", \%params);
	
	if ($response->is_success) {
		my $array = $json->decode($response->decoded_content);
		$self->{array} = $array;
		$self->{isa} = $object;
		
		return scalar(@$array);
	}else{
		return $response->status_line;
	}
}

1;
