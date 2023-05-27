# ABSTARCT: Internal iterator class for OpenSky::API

package OpenSky::API::Utils::Iterator;

our $VERSION = '0.001';
use OpenSky::API::Moose types => [
    qw(
      ArrayRef
      Defined
      InstanceOf
      PositiveOrZeroInt
    )
];

param '_rows' => (
    isa      => ArrayRef [Defined],
    init_arg => 'rows',
);

field '_index' => (
    is      => 'rw',
    writer  => 1,
    isa     => PositiveOrZeroInt,
    default => 0,
);

method first() {
    return $self->_rows->[0];
}

method next() {
    my $i    = $self->_index;
    my $next = $self->_rows->[$i] or return;
    $self->_set_index( $i + 1 );
    return $next;
}

method reset() {
    $self->set_index(0);
    return 1;
}

method all() {
    return @{ $self->_rows };
}

method count() {
    my @all = $self->all;
    return scalar @all;
}

__END__

=head1 SYNOPSIS

    use OpenSky::API::Utils::Iterator;

    my $results = OpenSky::API::Utils::Iterator->new( rows => [ 1, 2, 3 ] );

    while ( my $result = $results->next ) {
        ...
    }

=head1 DESCRIPTION

A simple iterator class. To keep it dead simple, it only allows defined values
to be passed in.

=head1 METHODS

=head2 C<next>

    while ( my $result = $results->next ) {
        ...
    }

Returns the next member in the iterator. Returns C<undef> if the iterator is
exhausted.

=head2 C<count>

    if ( $results->count ) {
        ...
    }

Returns the number of members in the iterator.

=head2 C<first>

    my $object = $results->first;

Returns the first object in the results.

=head2 C<reset>

    $results->reset;

Resets the iterator to point to the first member.

=head2 C<all>

    my @objects = $results->all;

Returns a list of all members in the iterator.
