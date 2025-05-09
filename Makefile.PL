use strict;
use warnings;

use 5.020000;

use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
  "ABSTRACT" => "Perl interface to the OpenSky Network API",
  "AUTHOR" => "Curtis \"Ovid\" Poe <curtis.poe\@gmail.com>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0
  },
  "DISTNAME" => "WebService-OpenSky",
  "LICENSE" => "artistic_2",
  "MIN_PERL_VERSION" => "5.020000",
  "NAME" => "WebService::OpenSky",
  "PREREQ_PM" => {
    "Config::INI::Reader" => 0,
    "Mojo::JSON" => 0,
    "Mojo::URL" => 0,
    "Mojo::UserAgent" => 0,
    "MooseX::Extended" => "0.35",
    "MooseX::Extended::Custom" => 0,
    "PerlX::Maybe" => 0,
    "Type::Library" => 0,
    "Type::Params" => 0,
    "Type::Utils" => 0,
    "Types::Common::Numeric" => 0,
    "Types::Common::String" => 0,
    "Types::Standard" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "Capture::Tiny" => 0,
    "Carp" => 0,
    "Exporter" => 0,
    "ExtUtils::MakeMaker" => 0,
    "File::Spec" => 0,
    "Test::More" => 0,
    "Test::Most" => 0,
    "experimental" => 0,
    "lib" => 0,
    "parent" => 0,
    "strict" => 0
  },
  "VERSION" => "0.5",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Capture::Tiny" => 0,
  "Carp" => 0,
  "Config::INI::Reader" => 0,
  "Exporter" => 0,
  "ExtUtils::MakeMaker" => 0,
  "File::Spec" => 0,
  "Mojo::JSON" => 0,
  "Mojo::URL" => 0,
  "Mojo::UserAgent" => 0,
  "MooseX::Extended" => "0.35",
  "MooseX::Extended::Custom" => 0,
  "PerlX::Maybe" => 0,
  "Test::More" => 0,
  "Test::Most" => 0,
  "Type::Library" => 0,
  "Type::Params" => 0,
  "Type::Utils" => 0,
  "Types::Common::Numeric" => 0,
  "Types::Common::String" => 0,
  "Types::Standard" => 0,
  "experimental" => 0,
  "lib" => 0,
  "parent" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
