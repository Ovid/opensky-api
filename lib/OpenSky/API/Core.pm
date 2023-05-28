package OpenSky::API::Core;

use Moose;
use OpenSky::API::Types qw(
  ArrayRef
  Defined
  InstanceOf
  Num
  PositiveOrZeroInt
  Str
  Undef
);
our $VERSION = '0.003';
use experimental qw(signatures);

around 'BUILDARGS' => sub ( $orig, $class, $state ) {
    my %value_for;
    @value_for{ $class->_get_params } = @$state;
    return $class->$orig(%value_for);
};

sub _get_params ($class) {
    croak("You must override _get_params in $class");
}

1;
