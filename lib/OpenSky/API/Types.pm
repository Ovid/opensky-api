# ABSTRACT: Type library for OpenSky::API

package OpenSky::API::Types;
our $VERSION = '0.001';
use Type::Library
  -base,
  -declare => qw(
  Longitude
  Latitude
  );

use Type::Utils -all;

BEGIN {
    extends qw(
      Types::Standard
      Types::Common::Numeric
      Types::Common::String
    );
}

declare Longitude, as Num, where { $_ >= -180 and $lon <= 180 };
declare Latitude,  as Num, where { $_ >= -90  and $lon <= 90 };

__END__

=head1 DESCRIPTION

No user-serviceable parts inside.

=head1 CUSTOM TYPES

=heaed2 Longitude

A number between -180 and 180, inclusive.

=head2 Latitude

A number between -90 and 90, inclusive.
