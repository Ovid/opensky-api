package WebService::OpenSky::Response::States;

# ABSTRACT: A class representing a states response from the OpenSky Network API
use WebService::OpenSky::Moose;
use WebService::OpenSky::Core::StateVector;
extends 'WebService::OpenSky::Response';

our $VERSION = '0.4';

method _create_response_objects() {
    return [ map { WebService::OpenSky::Core::StateVector->new($_) } $self->raw_response->{states}->@* ];
}

method _empty_response() {
    return {
        time   => 0,
        states => [],
    };
}

__END__

=head1 DESCRIPTION

This class inherits from L<WebService::OpenSky::Response>. Please see that
module for the available methods. Individual responses are from the
L<WebService::OpenSky::Core::StateVector> class.
