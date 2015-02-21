package MyApp;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.90080;
use open qw(:std :utf8);

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
  ConfigLoader
  Static::Simple

  Authentication
  Authorization::Roles

  /;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in pi_pcs.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name     => 'MyApp',
    encoding => 'UTF-8',

    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header                      => 1,    # Send X-Catalyst header

);

before 'setup_components' => sub {
    my $app = shift;

    if ( $ENV{HARNESS_ACTIVE} || $0 =~ /forkprove/ ) {
        $app->config->{'Model::DB'}{connect_info} = $app->config->{'Model::DB'}{testing_connect_info};
    }
};


after 'setup_components' => sub {
    my $app = shift;
    for ( keys %{ $app->components } ) {
        if ( $app->components->{$_}->can('initialize_after_setup') ) {
            $app->components->{$_}->initialize_after_setup($app);
        }
    }

};

after setup_finalize => sub {
    my $app = shift;

    for ( $app->registered_plugins ) {
        if ( $_->can('initialize_after_setup') ) {
            $_->initialize_after_setup($app);
        }
    }
};

use Log::Log4perl qw(:easy);

Log::Log4perl->easy_init(
    {
        level  => $DEBUG,
        layout => '[%P] %d %m%n',
        ( $ENV{ERROR_LOG} && -e $ENV{ERROR_LOG} ? ( file => '>>' . $ENV{ERROR_LOG} ) : () ),
        'utf8' => 1
    }
);

__PACKAGE__->log( get_logger() );

# Start the application
__PACKAGE__->setup();

=head1 NAME

MyApp - Catalyst based application

=head1 SYNOPSIS

    script/pi_pcs_server.pl

=head1 SEE ALSO

L<MyApp::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Renato CRON

=head1 LICENSE

This library is private software.

=cut

1;
