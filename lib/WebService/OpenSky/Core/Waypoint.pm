# ABSTRACT: Waypoint class

package WebService::OpenSky::Core::Waypoint;

our $VERSION = '0.009';

use Moose;
use experimental qw(signatures);

sub _get_params ($class) {
    return qw(
      time
      latitude
      longitude
      baro_altitude
      true_track
      on_ground
    );
}
has [ __PACKAGE__->_get_params() ] => ( is => 'ro', required => 1 );

around 'BUILDARGS' => sub ( $orig, $class, $waypoint ) {
    my %value_for;
    @value_for{ $class->_get_params } = @$waypoint;
    return $class->$orig(%value_for);
};

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
L<OpenSky waypoint responses|https://openskynetwork.github.io/opensky-api/rest.html#track-by-aircraft>.

All attributes are read-only.

=head1 METHODS

=head2 C<time>

Time which the given waypoint is associated with in seconds since epoch (Unix time).

=head2 C<latitude>

WGS-84 latitude in decimal degrees. Can be null.

=head2 C<longitude>

WGS-84 longitude in decimal degrees. Can be null.

=head2 C<baro_altitude>

Barometric altitude in meters. Can be null.

=head2 C<true_track>

True track in decimal degrees clockwise from north (north=0°). Can be null.

=head2 C<on_ground>

Boolean value which indicates if the position was retrieved from a surface position report.
