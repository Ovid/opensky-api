package WebService::OpenSky::Utils::Iterator;

# ABSTRACT: Internal iterator class for WebService::OpenSky

use Moose;
use WebService::OpenSky::Types qw(
  ArrayRef
  Defined
  InstanceOf
  PositiveOrZeroInt
);
use experimental qw(signatures);

our $VERSION = '0.3';

has '_rows' => (
    is       => 'ro',
    isa      => ArrayRef [Defined],
    init_arg => 'rows',
);

has '_index' => (
    is      => 'rw',
    writer  => '_set_index',
    isa     => PositiveOrZeroInt,
    default => 0,
);

sub first ($self) {
    return $self->_rows->[0];
}

sub next ($self) {    ## no critic (Subroutines::ProhibitBuiltinHomonyms)
    my $i    = $self->_index;
    my $next = $self->_rows->[$i] or return;
    $self->_set_index( $i + 1 );
    return $next;
}

sub reset ($self) {    ## no critic (Subroutines::ProhibitBuiltinHomonyms)
    $self->_set_index(0);
    return 1;
}

sub all ($self) {
    return @{ $self->_rows };
}

sub count ($self) {
    my @all = $self->all;
    return scalar @all;
}

__PACKAGE__->meta->make_immutable;

__END__

=head1 SYNOPSIS

    use WebService::OpenSky::Utils::Iterator;

    my $results = WebService::OpenSky::Utils::Iterator->new( rows => [ 1, 2, 3 ] );

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
