# A class representing a flights response from the OpenSky Network API

package OpenSky::API::Flights;

our $VERSION = '0.001';
use OpenSky::API::Moose types => [qw(InstanceOf)];
use OpenSky::API::Core::Flight;
use OpenSky::API::Utils::Iterator;

param flights => ( isa => InstanceOf ['OpenSky::API::Utils::Iterator'] );

around 'BUILDARGS' => sub ( $orig, $class, $response ) {
    my @flights  = map { OpenSky::API::Core::Flight->new($_) } $response->@*;
    my $iterator = OpenSky::API::Utils::Iterator->new( rows => \@flights );

    return $class->$orig( flights => $iterator );
};

=head1 METHODS

=head2 flights

Returns an iterator of L<OpenSky::API::Core::Flight> objects.
