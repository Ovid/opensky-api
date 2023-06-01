# ABSTRACT: A class representing a flights response from the OpenSky Network API

package WebService::OpenSky::Flights;

our $VERSION = '0.005';
use Moose;
use WebService::OpenSky::Core::Flight;
use WebService::OpenSky::Utils::Iterator;
use experimental qw(signatures);
extends 'WebService::OpenSky::Response';

sub _create_response_iterator ($self) {
    my @responses = map { WebService::OpenSky::Core::Flight->new($_) } $self->raw_response->@*;
    return WebService::OpenSky::Utils::Iterator->new( rows => \@responses );
}

# trusted method only called by WebService::OpenSky
sub _empty_response ($self) {
    return [];
}

__PACKAGE__->meta->make_immutable;

__END__

=head1 DESCRIPTION

This class inherits from L<WebService::OpenSky::Response>. Please see that
module for the available methods. Individual responses are from the
L<WesbService::OpenSky::Core::Flight> class.
