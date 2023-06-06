package WebService::OpenSky::Response::Flights;

# ABSTRACT: A class representing a flights response from the OpenSky Network API

use WebService::OpenSky::Moose;
use WebService::OpenSky::Core::Flight;
extends 'WebService::OpenSky::Response';

our $VERSION = '0.3';

method _create_response_objects() {
    return [ map { WebService::OpenSky::Core::Flight->new($_) } $self->raw_response->@* ];
}

method _empty_response() {
    return [];
}

__END__

=head1 DESCRIPTION

This class inherits from L<WebService::OpenSky::Response>. Please see that
module for the available methods. Individual responses are from the
L<WebService::OpenSky::Core::Flight> class.
