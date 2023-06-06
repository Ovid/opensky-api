# ABSTRACT: Flight class

package WebService::OpenSky::Core::Flight;

our $VERSION = '0.2';

use Moose;
use experimental qw(signatures);

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
has [ __PACKAGE__->_get_params() ] => ( is => 'ro', required => 1 );

__PACKAGE__->meta->make_immutable;

__END__

=head1 SYNOPSIS

    use WebService::OpenSky;
    my $opensky = WebService::OpenSky->new;
    my $flights  = $opensky->get_arrivals_by_airport('KLAX', $start, $end);
    while ( my $flight = $flights->next ) {
        say $flight->callsign;
    }

=head1 DESCRIPTION

This class is not to be instantiated directly. It is a read-only class representing 
L<OpenSky flight responses|https://openskynetwork.github.io/opensky-api/rest.html#flights-in-time-interval>.

All attributes are read-only.

=head1 METHODS

=head2 icao24

Unique ICAO 24-bit address of the transponder in hex string representation.
All letters are lower case.

=head2 firstSeen

Estimated time of departure for the flight as Unix time (seconds since epoch).

=head2 estDepartureAirport

ICAO code of the estimated departure airport. Can be null if the airport could
not be identified.

=head2 lastSeen

Estimated time of arrival for the flight as Unix time (seconds since epoch)

=head2 estArrivalAirport

ICAO code of the estimated arrival airport. Can be null if the airport could
not be identified.

=head2 callsign

Callsign of the vehicle (8 chars). Can be null if no callsign has been
received. If the vehicle transmits multiple callsigns during the flight, we
take the one seen most frequently.

=head2 estDepartureAirportHorizDistance

Horizontal distance of the last received airborne position to the estimated

=head2 estDepartureAirportVertDistance

Vertical distance of the last received airborne position to the estimated
departure airport in meters

=head2 estArrivalAirportHorizDistance

Horizontal distance of the last received airborne position to the estimated
arrival airport in meters

=head2 estArrivalAirportVertDistance

Vertical distance of the last received airborne position to the estimated
arrival airport in meters

=head2 departureAirportCandidatesCount

Number of other possible departure airports. These are airports in short
distance to C<estDepartureAirport>.

=head2 arrivalAirportCandidatesCount

Number of other possible departure airports. These are airports in short
distance to C<estArrivalAirport>.
