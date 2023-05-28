# A class representing a flights response from the OpenSky Network API

package OpenSky::API::Flights;

our $VERSION = '0.001';
use Moose;
use OpenSky::API::Types qw(InstanceOf);
use OpenSky::API::Core::Flight;
use OpenSky::API::Utils::Iterator;
use experimental qw(signatures);

has flights => (
    is      => 'ro',
    isa     => InstanceOf ['OpenSky::API::Utils::Iterator'],
    handles => [qw(first next reset all count)],
);

around 'BUILDARGS' => sub ( $orig, $class, $response ) {
    my @flights  = map { OpenSky::API::Core::Flight->new($_) } $response->@*;
    my $iterator = OpenSky::API::Utils::Iterator->new( rows => \@flights );

    return $class->$orig( flights => $iterator );
};

__PACKAGE__->meta->make_immutable;

__END__

=head1 METHODS

=head2 flights

Returns an iterator of L<OpenSky::API::Core::Flight> objects.

As a convenience, the following methods are delegated to the iterator:

=over 4

=item * first

=item * next

=item * reset

=item * all

=item * count


