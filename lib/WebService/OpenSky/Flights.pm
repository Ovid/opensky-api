# A class representing a flights response from the OpenSky Network API

package WebService::OpenSky::Flights;

our $VERSION = '0.005';
use Moose;
use WebService::OpenSky::Types qw(InstanceOf);
use WebService::OpenSky::Core::Flight;
use WebService::OpenSky::Utils::Iterator;
use experimental qw(signatures);

has flights => (
    is      => 'ro',
    isa     => InstanceOf ['WebService::OpenSky::Utils::Iterator'],
    handles => [qw(first next reset all count)],
);

around 'BUILDARGS' => sub ( $orig, $class, $response ) {
    my @flights  = map { WebService::OpenSky::Core::Flight->new($_) } $response->@*;
    my $iterator = WebService::OpenSky::Utils::Iterator->new( rows => \@flights );

    return $class->$orig( flights => $iterator );
};

__PACKAGE__->meta->make_immutable;

__END__

=head1 METHODS

=head2 flights

Returns an iterator of L<WebService::OpenSky::Core::Flight> objects.

As a convenience, the following methods are delegated to the iterator:

=over 4

=item * first

=item * next

=item * reset

=item * all

=item * count

=back
