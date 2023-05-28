# see also https://github.com/openskynetwork/opensky-api

package OpenSky::API;

# ABSTRACT: Perl interface to the OpenSky Network API

our $VERSION = '0.001';
use Moose;
use OpenSky::API::Types qw(
  ArrayRef
  Bool
  Dict
  HashRef
  InstanceOf
  Int
  Latitude
  Longitude
  NonEmptyStr
  Num
  Optional
);
use OpenSky::API::States;
use OpenSky::API::Flights;
use PerlX::Maybe;
use Config::INI::Reader;
use Carp qw( croak );

use Mojo::UserAgent;
use Mojo::URL;
use Mojo::JSON qw( decode_json );
use Type::Params -sigs;
use experimental qw( signatures );

has config => (
    is      => 'ro',
    isa     => NonEmptyStr,
    default => sub ($self) { $ENV{HOME} . '/.openskyrc' },
);

has [qw/debug raw testing/] => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

has _config_data => (
    is       => 'ro',
    isa      => HashRef,
    init_arg => undef,
    lazy     => 1,
    default  => sub ($self) {
        Config::INI::Reader->read_file( $self->config );
    },
);

has _ua => (
    is       => 'ro',
    isa      => InstanceOf ['Mojo::UserAgent'],
    init_arg => undef,
    default  => sub { Mojo::UserAgent->new },
);

has _username => (
    is       => 'ro',
    isa      => NonEmptyStr,
    lazy     => 1,
    init_arg => 'username',
    default  => sub ($self) { $ENV{OPENSKY_USERNAME} // $self->_config_data->{opensky}{username} },
);

has _password => (
    is       => 'ro',
    isa      => NonEmptyStr,
    lazy     => 1,
    init_arg => 'password',
    default  => sub ($self) { $ENV{OPENSKY_PASSWORD} // $self->_config_data->{opensky}{password} },
);

has _base_url => (
    is       => 'ro',
    init_arg => 'base_url',
    isa      => NonEmptyStr,
    default  => sub ($self) {'https://opensky-network.org/api'},
);

has limit_remaining => (
    is      => 'ro',
    isa     => Int,
    lazy    => 1,
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

sub get_states ( $self, $seconds, $icao24, $bbox, $extended ) {
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
        time   => time - ( $seconds // 0 ),
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

sub get_my_states ( $self, $seconds, $icao24, $serials ) {
    my %params = (
        extended      => 1,
        maybe time    => $seconds,
        maybe icao24  => $icao24,
        maybe serials => $serials,
    );

    my $route    = '/states/own';
    my $response = $self->_get_response( route => $route, params => \%params );
    if ( $self->raw ) {
        return $response;
    }
    return OpenSky::API::States->new($response);
}

sub get_flights_from_interval ( $self, $begin, $end ) {
    if ( $begin >= $end ) {
        croak 'The end time must be greater than or equal to the start time.';
    }
    if ( ( $end - $begin ) > 7200 ) {
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

sub get_flights_by_aircraft ( $self, $icao24, $begin, $end ) {
    if ( $begin >= $end ) {
        croak 'The end time must be greater than or equal to the start time.';
    }
    if ( ( $end - $begin ) > 2592 * 1e3 ) {
        croak 'The time interval must be smaller than 30 days.';
    }

    my %params   = ( icao24 => $icao24, begin => $begin, end => $end );
    my $route    = '/flights/aircraft';
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
sub _GET ( $self, $url ) {
    return $self->_ua->get($url)->res;
}

sub _get_response ( $self, $route, $params, $credits ) {
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

sub _debug ( $self, $msg ) {
    return if !$self->debug;
    say STDERR $msg;
}

sub _url ( $self, $url, $params = {} ) {
    $url = Mojo::URL->new( $self->_base_url . $url )->userinfo( $self->_username . ':' . $self->_password );
    $url->query($params);
    return $url;
}

__PACKAGE__->meta->make_immutable;
