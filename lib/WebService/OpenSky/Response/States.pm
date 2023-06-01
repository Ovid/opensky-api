# ABSTRACT: A class representing a states response from the OpenSky Network API

package WebService::OpenSky::Response::States;

our $VERSION = '0.007';
use Moose;
use WebService::OpenSky::Core::StateVector;
use experimental qw(signatures);
extends 'WebService::OpenSky::Response';

sub _create_response_objects ($self) {
    return [ map { WebService::OpenSky::Core::StateVector->new($_) } $self->raw_response->{states}->@* ];
}

sub _empty_response ($self) {
    return {
        time   => 0,
        states => [],
    };
}
__PACKAGE__->meta->make_immutable;

__END__

=head1 DESCRIPTION

This class inherits from L<WebService::OpenSky::Response>. Please see that
module for the available methods. Individual responses are from the
L<WebService::OpenSky::Core::StateVector> class.
