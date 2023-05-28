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
use experimental qw(signatures);

around 'BUILDARGS' => sub ( $orig, $class, $state ) {
    my %value_for;
    state $params_installed;
    if ( not $params_installed ) {
        $class->meta->make_mutable;
        param [ $class->_get_params() ] => ( required => 1 );
        $class->meta->make_immutable unless $^P;
        $params_installed++;
    }
    @value_for{ $class->_get_params } = @$state;
    return $class->$orig(%value_for);
};

sub _get_params ($class) {
    croak("You must override _get_params in $class");
}
