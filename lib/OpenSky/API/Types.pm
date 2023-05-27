package OpenSky::API::Types {
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
}
