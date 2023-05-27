package OpenSky::API::States {
    use OpenSky::API::Moose types => [
        qw(
          InstanceOf
          PositiveOrZeroInt
        )
    ];
    use OpenSky::API::Core::StateVector;
    use OpenSky::API::Utils::Iterator;

    param time    => ( isa => PositiveOrZeroInt );
    param vectors => ( isa => InstanceOf ['OpenSky::API::Utils::Iterator'] );

    around 'BUILDARGS' => sub ( $orig, $class, $response ) {

        my $states = $response->{states};
        my $time   = $response->{time};

        my @state_vectors = map { OpenSky::API::Core::StateVector->new($_) } @$states;
        my $iterator      = OpenSky::API::Utils::Iterator->new( rows => \@state_vectors );

        return $class->$orig( vectors => $iterator, time => $time );
    };
}
