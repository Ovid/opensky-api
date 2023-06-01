# This file is generated by Dist::Zilla::Plugin::CPANFile v6.030
# Do not edit this file directly. To change prereqs, edit the `dist.ini` file.

requires "Carp" => "0";
requires "Config::INI::Reader" => "0";
requires "Mojo::JSON" => "0";
requires "Mojo::URL" => "0";
requires "Mojo::UserAgent" => "0";
requires "Moose" => "0";
requires "PerlX::Maybe" => "0";
requires "Type::Library" => "0";
requires "Type::Params" => "0";
requires "Type::Utils" => "0";
requires "Types::Common::Numeric" => "0";
requires "Types::Common::String" => "0";
requires "Types::Standard" => "0";
requires "experimental" => "0";

on 'test' => sub {
  requires "Exporter" => "0";
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "Test2::Plugin::BailOnFail" => "0";
  requires "Test::More" => "0";
  requires "Test::Most" => "0";
  requires "Test::PerlTidy" => "0";
  requires "lib" => "0";
  requires "parent" => "0";
  requires "strict" => "0";
  requires "warnings" => "0";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "File::Spec" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::More" => "0";
  requires "Test::Pod" => "1.41";
  requires "perl" => "5.006";
  requires "strict" => "0";
  requires "warnings" => "0";
};
