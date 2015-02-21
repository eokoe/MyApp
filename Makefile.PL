#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'MyApp';
all_from 'lib/MyApp.pm';

requires 'Catalyst::Runtime' => '5.90080';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::DBIC::Schema';

requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';

requires 'Log::Log4perl';

requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Component::InstancePerContext';


requires 'Catalyst::Controller::REST';

requires 'DBIx::Class::PassphraseColumn';
requires 'DBIx::Class::TimeStamp';
requires 'Moose';

requires 'namespace::autoclean';
requires 'MooseX::Types::Email';

requires 'Data::Diver';
requires 'Data::Manager';

requires 'Data::Printer';

requires 'FindBin';

requires 'JSON';
requires 'JSON::XS';

requires 'DateTime::Format::Pg';

requires 'Digest::MD5';

requires 'MooseX::Traits';
requires 'DBD::Pg';


requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
test_requires 'Test::More' => '0.88';
test_requires 'Test::Deep';
tests_recursive('t');
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;



