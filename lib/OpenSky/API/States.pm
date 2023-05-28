# ,A class representing a states response from the OpenSky Network API

package OpenSky::API::States;

our $VERSION = '0.001';
use Moose;
use OpenSky::API::Types qw(
  InstanceOf
  PositiveOrZeroInt
);
use OpenSky::API::Core::StateVector;
use OpenSky::API::Utils::Iterator;
use experimental qw(signatures);

has time => ( is => 'ro', isa => PositiveOrZeroInt );
has vectors => (
    is      => 'ro',
    isa     => InstanceOf ['OpenSky::API::Utils::Iterator'],
    handles => [qw(first next reset all count)],
);

around 'BUILDARGS' => sub ( $orig, $class, $response ) {
    my $states = $response->{states};
    my $time   = $response->{time};

    my @state_vectors = map { OpenSky::API::Core::StateVector->new($_) } @$states;
    my $iterator      = OpenSky::API::Utils::Iterator->new( rows => \@state_vectors );

    return $class->$orig( vectors => $iterator, time => $time );
};

__PACKAGE__->meta->make_immutable;

=head1 METHODS

=head2 time

The time which the state vectors in this response are associated with. All
vectors represent the state of a vehicle with the interval C<[time=1, time]>.

=head2 vectors

Returns an iterator of L<OpenSky::API::Core::StateVector> objects.

As a convenience, the following methods are delegated to the iterator:

=over 4

=item * first

=item * next

=item * reset

=item * all

=item * count

=back
