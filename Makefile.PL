use strict;
use warnings;



use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
  "ABSTRACT" => "Perl interface to the OpenSky Network API",
  "AUTHOR" => "Curtis \"Ovid\" Poe <curtis.poe\@gmail.com>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0
  },
  "DISTNAME" => "OpenSky-API",
  "LICENSE" => "artistic_2",
  "NAME" => "OpenSky::API",
  "PREREQ_PM" => {
    "Config::INI::Reader" => 0,
    "Function::Parameters" => "2.002003",
    "Mojo::JSON" => 0,
    "Mojo::URL" => 0,
    "Mojo::UserAgent" => 0,
    "MooseX::Extended::Custom" => 0,
    "PerlX::Maybe" => 0,
    "Type::Library" => 0,
    "Type::Params" => 0,
    "Type::Utils" => 0,
    "Types::Common::Numeric" => 0,
    "Types::Common::String" => 0,
    "Types::Standard" => 0
  },
  "TEST_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0,
    "File::Spec" => 0,
    "Test::More" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.001",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Config::INI::Reader" => 0,
  "ExtUtils::MakeMaker" => 0,
  "File::Spec" => 0,
  "Function::Parameters" => "2.002003",
  "Mojo::JSON" => 0,
  "Mojo::URL" => 0,
  "Mojo::UserAgent" => 0,
  "MooseX::Extended::Custom" => 0,
  "PerlX::Maybe" => 0,
  "Test::More" => 0,
  "Type::Library" => 0,
  "Type::Params" => 0,
  "Type::Utils" => 0,
  "Types::Common::Numeric" => 0,
  "Types::Common::String" => 0,
  "Types::Standard" => 0,
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
