# ABSTRACT: A class representing a response from the OpenSky Network API

package WebService::OpenSky::Response;

our $VERSION = '0.008';
use Moose;
use WebService::OpenSky::Utils::Iterator;
use WebService::OpenSky::Types qw(
  ArrayRef
  Bool
  HashRef
  InstanceOf
  Route
);
use Carp 'croak';
use experimental qw(signatures);

has raw_response => (
    is      => 'ro',
    isa     => ArrayRef | HashRef,
    default => sub ($self) { $self->_empty_response },
);

has route => (
    is       => 'ro',
    isa      => Route,
    required => 1,
);

has query => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has _iterator => (
    is       => 'rw',
    isa      => InstanceOf ['WebService::OpenSky::Utils::Iterator'],
    writer   => '_set_iterator',
    init_arg => undef,
);

has _inflated => (
    is       => 'rw',
    isa      => Bool,
    default  => 0,
    init_arg => undef,
);

sub BUILD ( $self, @ ) {
    if ( !$self->raw_response ) {
        $self->raw_response( $self->_empty_response );
    }
}

sub _inflate ($self) {
    return if $self->_inflated;
    my $iterator = WebService::OpenSky::Utils::Iterator->new( rows => $self->_create_response_objects );
    $self->_set_iterator($iterator);
    $self->_inflated(1);
}

sub _create_response_iterator ($self) {
    croak 'This method must be implemented by a subclass';
}

sub _empty_response ($self) {
    croak 'This method must be implemented by a subclass';
}

sub iterator ($self) {
    $self->_inflate;
    return $self->_iterator;
}

sub next ($self) {
    $self->_inflate;
    return $self->iterator->next;
}

sub first ($self) {
    $self->_inflate;
    return $self->iterator->first;
}

sub reset ($self) {
    $self->_inflate;
    return $self->iterator->reset;
}

sub all ($self) {
    $self->_inflate;
    return $self->iterator->all;
}

sub count ($self) {
    $self->_inflate;
    return $self->iterator->count;
}

__PACKAGE__->meta->make_immutable;

__END__

=head1 DESCRIPTION

This class represents iterator from the OpenSky Network API. By default, it does
not instantiate individual response objects until you first ask for them. This is for performance reasons.

=head1 METHODS

=head2 raw_response

The raw response from the OpenSky Network API.

=head2 route

The route used to retrieve this response.

=head2 query

The query used to retrieve this response.

=head2 iterator

Returns an iterator of results. See L<WebService::OpenSky> to understand the
actual response class returned for a given method and which underlying module
represents the results. (Typically this would be
L<WebService::OpenSky::Core::Flight> or
L<WebService::OpenSky::Core::StateVector>.)

As a convenience, the following methods are delegated to the iterator:

=over 4

=item * first

=item * next

=item * reset

=item * all

=item * count

=back
