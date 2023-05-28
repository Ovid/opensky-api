package OpenSky::API::Role::Core;

use MooseX::Extended::Role;

requires '_get_params';

around 'BUILDARGS' => sub ( $orig, $class, $state ) {
    my %value_for;
    @value_for{ $class->_get_params } = @$state;
    return $class->$orig(%value_for);
};

