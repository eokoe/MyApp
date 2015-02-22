package MyApp::Controller::API::Facebook;

use Moose;
use Facebook::OpenGraph;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub base : Chained('/api/root') : PathPart('facebook') : CaptureArgs(0) { }


sub user_information : Chained('base') : PathPart('user-information') : Args(0) : ActionClass('REST') { }

sub user_information_GET {
    my ($self, $c) = @_;

    $self->validate_request_params(
        $c,
        access_token => {
            type     => 'Str',
            required => 1,
        },
    );

    my $fb = Facebook::OpenGraph->new({
        access_token => $c->req->params->{access_token}
    });

    my $test = $fb->get('/me');

    $self->status_ok( $c, entity => {
        status => $test
    } );
}


1;
