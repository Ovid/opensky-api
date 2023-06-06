# ABSTRACT: A class representing a flight track from the OpenSky Network API

package WebService::OpenSky::Response::FlightTrack;

our $VERSION = '0.1';
use Moose;
use WebService::OpenSky::Core::Waypoint;
use experimental qw(signatures);
extends 'WebService::OpenSky::Response';

my @ATTRS = qw(
  icao24
  callsign
  startTime
  endTime
  path
);

has [@ATTRS] => ( is => 'rw', required => 0 );

sub BUILD ( $self, @ ) {
    foreach my $attr (@ATTRS) {
        $self->$attr( $self->raw_response->{$attr} );
    }
}

sub _create_response_objects ($self) {
    my @path = map { WebService::OpenSky::Core::Waypoint->new($_) } $self->path->@*;
    $self->path( \@path );
    return \@path;
}

sub _empty_response ($self) {
    return { path => [] };
}

__PACKAGE__->meta->make_immutable;

__END__

=head1 DESCRIPTION

A set of "waypoints" for a given aircraft flight.

This class inherits from L<WebService::OpenSky::Response>. Please see that
module for the available methods. Individual responses are from the
L<WebService::OpenSky::Core::Waypoint> class.

=head1 ADDITIONAL ATTRIBUTES

In addition to the methods and attributes provided by the parent class, this
class provides the following:

=head2 C<icao24>

The ICAO24 ID of the aircraft.

=head2 C<callsign>

The callsign of the aircraft. Can be C<undef>.

=head2 C<startTime>

The time of the first waypoint in seconds since epoch (Unix time).

=head2 C<endTime>

The time of the last waypoint in seconds since epoch (Unix time).

=head2 C<waypoints>

The waypoints of the flight. This is an arrayref of L<WebService::OpenSky::Core::Waypoint> objects.
