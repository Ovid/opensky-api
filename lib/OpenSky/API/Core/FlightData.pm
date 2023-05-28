# ABSTRACT: FlightData class

package OpenSky::API::Core::FlightData;

our $VERSION = '0.001';

use OpenSky::API::Moose;
extends 'OpenSky::API::Core';

sub _get_params ($class) {
    return qw(
      icao24
      firstSeen
      estDepartureAirport
      lastSeen
      estArrivalAirport
      callsign
      estDepartureAirportHorizDistance
      estDepartureAirportVertDistance
      estArrivalAirportHorizDistance
      estArrivalAirportVertDistance
      departureAirportCandidatesCount
      arrivalAirportCandidatesCount
    );
}

=head1 DESCRIPTION

This class is not to be instantiated directly. It is a read-only class representing 
L<OpenSky flight responses|https://openskynetwork.github.io/opensky-api/rest.html#flights-in-time-interval>.

All attributes are read-only.

