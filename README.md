# NAME

WebService::OpenSky - Perl interface to the OpenSky Network API

# VERSION

version 0.4

# SYNOPSIS

```perl
use WebService::OpenSky;

my $api = WebService::OpenSky->new(
    username => 'username',
    password => 'password',
);

my $states = $api->get_states;
while ( my $vector = $states->next ) {
    say $vector->callsign;
}
```

# DESCRIPTION

This is a Perl interface to the OpenSky Network API. It provides a simple, object-oriented
interface, but also allows you to fetch raw results for performance.

This is largely based on [the official Python
implementation](https://github.com/openskynetwork/opensky-api/blob/master/python/opensky_api.py),
but with some changes to make it more user-friendly for Perl developers.

# CONSTRUCTOR

Basic usage:

```perl
my $open_sky = WebService::OpenSky->new;
```

This will create an instance of the API object with no authentication. This only allows you access
to the `get_states` method.

If you want to use the other methods, you will need to provide a username and password:

```perl
my $open_sky = WebService::OpenSky->new(
    username => 'username',
    password => 'password',
);
```

You can get a username and password by registering for a free account on
[OpenSky Network](https://opensky-network.org).

Alternatively, you can set the `OPENSKY_USERNAME` and `OPENSKY_PASSWORD`
environment variables, or create a `.openskyrc` file in your home directory
with the following contents:

```perl
[opensky]
username = myusername
password = s3cr3t
```

If you'd like that file in another directory, just pass the `config` argument:

```perl
my $open_sky = WebService::OpenSky->new(
    config => '/path/to/config',
);
```

All methods return objects. However, we don't inflate the results into objects
until you ask for the next result. This is to avoid inflating all results if it's expensive.
In that case, you can ask for the raw results:

```perl
my $open_sky = WebService::OpenSky->new->get_states;
my $raw = $open_sky->raw_response;
```

If you are debugging why something failed, pass the `debug` attribute to see
a `STDERR` trace of the requests and responses:

```perl
my $open_sky = WebService::OpenSky->new(
    debug => 1,
);
```

In the unlikely event that you need to change the base URL, you can do so:

```perl
    my $open_sky = WebService::OpenSky->new(
            base_url => 'https://opensky-network.org/api/v2',
    );
```

The base url defaults to [https://opensky-network.org/api](https://opensky-network.org/api).

# METHODS

For more insight to all methods, see [the OpenSky API
documentation](https://openskynetwork.github.io/opensky-api/).

Note a key difference between the Python implementation and this one: the
Python implementation returns <None> if results are not found. For this
module, you will still receive the iterator, but it won't have any results.
This allows you to keep a consistent interface without having to check for
`undef` everywhere.

## get\_states

```perl
my $states = $api->get_states;
```

Returns an instance of [WebService::OpenSky::Response::States](https://metacpan.org/pod/WebService%3A%3AOpenSky%3A%3AResponse%3A%3AStates).

This API call can be used to retrieve any state vector of the OpenSky. Please
note that rate limits apply for this call. For API calls without rate
limitation, see `get_my_states`.

By default, the above fetches all current state vectors.

You can (optionally) request state vectors for particular airplanes or times
using the following request parameters:

```perl
my $states = $api->get_states(
    icao24 => 'abc9f3',
    time   => 1517258400,
);
```

Both parameters are optional.

- `icao24`

    One or more ICAO24 transponder addresses represented by a hex string (e.g.
    abc9f3). To filter multiple ICAO24 append the property once for each address.
    If omitted, the state vectors of all aircraft are returned.

- `time`

    A Unix timestamp (seconds since epoch). Only state vectors after this timestamp are returned.

In addition to that, it is possible to query a certain area defined by a
bounding box of WGS84 coordinates. For this purpose, add the following
parameters:

```perl
my $states = $api->get_states(
    bbox => {
        lomin => -0.5,     # lower bound for the longitude in decimal degrees
        lamin => 51.25,    # lower bound for the latitude in decimal degrees
        lomax => 0,        # upper bound for the longitude in decimal degrees
        lamax => 51.75,    # upper bound for the latitude in decimal degrees
    },
);
```

You can also request the category of aircraft by adding the following request parameter:

```perl
my $states = $api->get_states(
    extended => 1,
);
```

Any and all of the above parameters can be combined.

```perl
my $states = $api->get_states(
    icao24   => 'abc9f3',
    time     => 1517258400,
    bbox     => {
        lomin => -0.5,     # lower bound for the longitude in decimal degrees
        lamin => 51.25,    # lower bound for the latitude in decimal degrees
        lomax => 0,        # upper bound for the longitude in decimal degrees
        lamax => 51.75,    # upper bound for the latitude in decimal degrees
    },
    extended => 1,
);
```

## get\_my\_states

```perl
my $states = $api->get_my_states;
```

Returns an instance of [WebService::OpenSky::Response::States](https://metacpan.org/pod/WebService%3A%3AOpenSky%3A%3AResponse%3A%3AStates).

This API call can be used to retrieve state vectors for your own sensors
without rate limitations. Note that authentication is required for this
operation, otherwise you will get a 403 - Forbidden.

By default, the above fetches all current state vectors for your states.
However, you can also pass arguments to fine-tune this:

```perl
my $states = $api->get_my_states(
    time    => 1517258400,
    icao24  => 'abc9f3',
    serials => [ 1234, 5678 ],
);
```

- `time`

    The time in seconds since epoch (Unix timestamp to retrieve states for.
    Current time will be used if omitted.

- &lt;icao24>

    One or more ICAO24 transponder addresses represented by a hex string (e.g.
    abc9f3). To filter multiple ICAO24 append the property once for each address.
    If omitted, the state vectors of all aircraft are returned.

- `serials`

    Retrieve only states of a subset of your receivers. You can pass this argument
    several time to filter state of more than one of your receivers. In this case,
    the API returns all states of aircraft that are visible to at least one of the
    given receivers.

## `get_arrivals_by_airport`

```perl
my $arrivals = $api->get_arrivals_by_airport('KJFK', $start, $end);
```

Returns an instance of [WebService::OpenSky::Response::Flights](https://metacpan.org/pod/WebService%3A%3AOpenSky%3A%3AResponse%3A%3AFlights).

Positional arguments:

- `airport`

    The ICAO code of the airport you want to get arrivals for.

- `start`

    The start time in seconds since epoch (Unix timestamp).

- `end`

    The end time in seconds since epoch (Unix timestamp).

The interval between start and end time must be smaller than seven days.

## `get_departures_by_airport`

Identical to `get_arrivals_by_airport`, but returns departures instead of arrivals.

## `get_flights_by_aircraft`

```perl
my $flights = $api->get_flights_by_aircraft($icao24, $start, $end);
```

Returns an instance of [WebService::OpenSky::Response::Flights](https://metacpan.org/pod/WebService%3A%3AOpenSky%3A%3AResponse%3A%3AFlights).

The first argument is the lower-case ICAO24 transponder address of the aircraft you want.

The second and third arguments are the start and end times in seconds since
epoch (Unix timestamp). Their interval must be equal to or less than 30 days.

## `get_flights_from_interval`

```perl
my $flights = $api->get_flights_from_interval($start, $end);
```

Returns an instance of [WebService::OpenSky::Response::Flights](https://metacpan.org/pod/WebService%3A%3AOpenSky%3A%3AResponse%3A%3AFlights).

## `get_track_by_aircraft`

```perl
    my $track = $api->get_track_by_aircraft( $icao24, $start );
```

Adds support for the experimental [GET
/tracks](https://openskynetwork.github.io/opensky-api/rest.html#track-by-aircraft)
endpoint. Returns an instance of
[WebService::OpenSky::Response::FlightTrack](https://metacpan.org/pod/WebService%3A%3AOpenSky%3A%3AResponse%3A%3AFlightTrack).

Per the OpenSky documentation, this endpoint is experimental and may be removed or simply
not working at any time.

## `limit_remaining`

```perl
my $limit = $api->limit_remaining;
```

Returns the number of API credits you have left. See
[https://openskynetwork.github.io/opensky-api/rest.html#limitations](https://openskynetwork.github.io/opensky-api/rest.html#limitations) for more
information.

If you have not yet made a request, this method will return `undef`.

## `delay_remaining($method)`

```perl
    my $delay = $api->delay_remaining('get_states');
```

When you call either `get_states` or `get_my_states`, the your calls will
be rate limited. This method returns the number of seconds you have to wait
until you can make another request. You can `sleep` that many seconds before making
a new call:

```
    sleep $api->delay_remaining('get_states');
```

If you attempt to make a request before the delay has expired, you will get a warning and
no request will be made.

See
[limitations](https://openskynetwork.github.io/opensky-api/rest.html#limitations)
for more details.

# EXAMPLES

Perl Wikipedia, [OpenSky Network](https://en.wikipedia.org/wiki/OpenSky_Network) is ...

```perl
The OpenSky Network is a non-profit association based in Switzerland that
provides open access of flight tracking control data. It was set up as
a research project by several universities and government entities with
the goal to improve the security, reliability and efficiency of the
airspace. Its main function is to collect, process and store air traffic
control data and provide open access to this data to the public. Similar
to many existing flight trackers such as Flightradar24 and FlightAware,
the OpenSky Network consists of a multitude of sensors (currently around
1000, mostly concentrated in Europe and the US), which are connected to
the Internet by volunteers, industrial supporters, academic, and
governmental organizations. All collected raw data is archived in a
large historical database, containing over 23 trillion air traffic control
messages (November 2020). The database is primarily used by researchers
from different areas to analyze and improve air traffic control
technologies and processes
```

## Elon Musk's Jet

However, this data can be used to track the movements of certain aircraft. For
example, Elon Musk's primary private jet (he has three, but this is the one he
mainly uses), has the ICAO24 transponder address `a835af`. Running the
following code ...

```perl
use WebService::OpenSky;

my $musks_jet = 'a835af';
my $openapi   = WebService::OpenSky->new;

my $days = shift @ARGV // 7;
my $now  = time;
my $then = $now - 86400 * $days;    # Max 30 days

my $flight_data = $openapi->get_flights_by_aircraft( $musks_jet, $then, $now );
say "Jet $musks_jet has " . $flight_data->count . " flights";
```

As of this writing, that prints out:

```
Jet a835af has 6 flights
```

# ETHICS

There are some ethical considerations to be made when using this module. I was
ambivalent about writing it, but I decided to do so because I think it's
important to be aware of the privacy implications. However, it's also
important to be aware of the [climate
implications](https://www.euronews.com/green/2023/03/30/wasteful-luxury-private-jet-pollution-more-than-doubles-in-europe).

Others are using the OpenSky API to model the amount of carbon being released
by the aviation industry, while others have used this public data to predict
corporate mergers and acquisitions. There are a wealth of reasons why this
data is useful, but not all of those reasons are good. Be good.

# AUTHOR

Curtis "Ovid" Poe <curtis.poe@gmail.com>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2023 by Curtis "Ovid" Poe.

This is free software, licensed under:

```
The Artistic License 2.0 (GPL Compatible)
```
