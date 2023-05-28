# see also https://github.com/openskynetwork/opensky-api

package OpenSky::API;

# ABSTRACT: Perl interface to the OpenSky Network API

our $VERSION = '0.001';
use OpenSky::API::Moose types => [
    qw(
      ArrayRef
      Bool
      Dict
      HashRef
      InstanceOf
      Int
      NonEmptyStr
      Num
      Optional
    )
];
use OpenSky::API::States;
use OpenSky::API::Flights;
use OpenSky::API::Types qw(
  Longitude
  Latitude
);
use PerlX::Maybe;
use Config::INI::Reader;

use Mojo::UserAgent;
use Mojo::URL;
use Mojo::JSON qw( decode_json );
use Type::Params -sigs;

param config => (
    isa     => NonEmptyStr,
    default => sub { $ENV{HOME} . '/.openskyrc' },
);

param [qw/debug raw testing/] => (
    isa     => Bool,
    default => 0,
);

field _config_data => (
    isa      => HashRef,
    required => 1,
    default  => sub { Config::INI::Reader->read_file( $_[0]->config ) },
);

field _ua => (
    isa     => InstanceOf ['Mojo::UserAgent'],
    default => sub { Mojo::UserAgent->new },
);

field _username => (
    isa     => NonEmptyStr,
    default => sub ($self) { $ENV{OPENSKY_USERNAME} // $self->_config_data->{opensky}{username} },
);

field _password => (
    isa     => NonEmptyStr,
    default => sub ($self) { $ENV{OPENSKY_PASSWORD} // $self->_config_data->{opensky}{password} },
);

field _base_url => (
    isa     => NonEmptyStr,
    default => sub ($self) { $self->_config_data->{_}{base_url} },
);

field limit_remaining => (
    isa     => Int,
    writer  => '_set_limit_remaining',
    default => sub ($self) {
        return 4000 if $self->testing;

        # per their documentation,
        # https://openskynetwork.github.io/opensky-api/rest.html#api-credit-usage,
        # this request should only cost one credit. However, it appears to
        # cost three.
        my %params = (
            lamin => 49.7,
            lomin => 3.2,
            lamax => 50.5,
            lomax => 4.6,
        );
        my $route = '/states/all';
        return $self->_get_response( route => $route, params => \%params, credits => 1 );
    },
);

signature_for get_states => (
    method => 1,
    named  => [
        time   => Optional [Num], { default => 0 },
        icao24 => Optional [ NonEmptyStr | ArrayRef [NonEmptyStr] ],
        bbox   => Optional [
            Dict [
                lamin => Latitude,
                lomin => Longitude,
                lamax => Latitude,
                lomax => Longitude,
            ],
            { default => {} },
        ],
        extended => Optional [Bool],
    ],
    named_to_list => 1,
);

method get_states( $seconds, $icao24, $bbox, $extended ) {
    my %params = (
        maybe time     => $seconds,
        maybe icao24   => $icao24,
        maybe extended => $extended,
    );
    if ( keys $bbox->%* ) {
        $params{$_} = $bbox->{$_} for qw( lamin lomin lamax lomax );
    }

    my $route    = '/states/all';
    my $response = $self->_get_response( route => $route, params => \%params ) // {
        time   => time - ($seconds // 0),
        states => [],
    };
    if ( $self->raw ) {
        return $response;
    }
    return OpenSky::API::States->new($response);
}

signature_for get_my_states => (
    method => 1,
    named  => [
        time    => Optional [Num], { default => 0 },
        icao24  => Optional [ NonEmptyStr | ArrayRef [NonEmptyStr] ],
        serials => Optional [ NonEmptyStr | ArrayRef [NonEmptyStr] ],
    ],
    named_to_list => 1,
);

method get_my_states( $seconds, $icao24, $serials ) {
    my %params = (
        extended      => 1,
        maybe time    => $seconds,
        maybe icao24  => $icao24,
        maybe serials => $serials,
    );

    my $route = '/states/own';
    my $response = $self->_get_response( route => $route, params => \%params );
    if ( $self->raw ) {
        return $response;
    }
    return OpenSky::API::States->new($response);
}

method get_flights_from_interval( $begin, $end ) {
    if ( $begin >= $end ) {
        croak 'The end time must be greater than or equal to the start time.';
    }
    if ( ($end - $begin) > 7200 ) {
        croak 'The time interval must be smaller than two hours.';
    }

    my %params   = ( begin => $begin, end => $end );
    my $route    = '/flights/all';
    my $response = $self->_get_response( route => $route, params => \%params ) // [];

    if ( $self->raw ) {
        return $response;
    }
    return OpenSky::API::Flights->new($response);
}

signature_for _get_response => (
    method => 1,
    named  => [
        route   => NonEmptyStr,
        params  => Optional [HashRef],
        credits => Optional [Bool],
    ],
    named_to_list => 1,
);

# an easy target to override
method _GET ($url) {
    return $self->_ua->get($url)->res;
}

method _get_response( $route, $params, $credits ) {
    my $url       = $self->_url( $route, $params );
    my $response  = $self->_GET($url);
    my $remaining = $response->headers->header('X-Rate-Limit-Remaining');

    $self->_debug("GET $url\n");
    $self->_debug( $response->headers->to_string . "\n" );

    # not all requests cost credits, so we only want to set the limit if
    # $remaining is defined
    $self->_set_limit_remaining($remaining) if !$credits && defined $remaining;
    if ( !$response->is_success ) {
        if ( $response->code == 404 ) {

            # this is annoying. If the didn't match any criteria, return a 200
            # and and empty element. Instead, we get a 404.
            return;
        }
        croak $response->to_string;
    }
    return $remaining if $credits;
    if ( $self->debug ) {
        $self->_debug( $response->body );
    }
    return decode_json( $response->body );
}

method _debug ($msg) {
    return if !$self->debug;
    say STDERR $msg;
}

method _url( $url, $params = {} ) {
    $url = Mojo::URL->new( $self->_base_url . $url )->userinfo( $self->_username . ':' . $self->_password );
    $url->query($params);
    return $url;
}
