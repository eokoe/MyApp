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

    # todo cachear esse access_token para nao consultar mais de 1x
    my $fb = Facebook::OpenGraph->new({
        access_token => $c->req->params->{access_token}
    });

    my $ret = {};
    eval {
        my $me = $fb->get('/me');
        my $pic = $fb->get('/me/picture?redirect=false&type=normal');

        delete $me->{verified};
        $ret->{facebook} = {
            %$me,
            picture => $pic->{data}{url},
        };
    };
    die \['access_token', 'expired'] if $@ && $@ =~ /Session has expired/;
    die $@ if $@; # fatal error..

    my $user_rs = $c->model('DB::User');
    my $user = $user_rs->search({ fb_clientid => $ret->{facebook}{id} })->next;
    if ($user){
        $ret->{session} = $user->new_session($c->req->address);
    }else{
        $user = $user_rs->search({ email => $ret->{facebook}{email} })->next;
        $ret->{session} = $user->new_session($c->req->address) if $user;
    }

    $ret->{has_account} = exists $ret->{session} ? 1 : 0;

    if ($ret->{has_account}){
        $user->setup_facebook({
            clientid                 => $ret->{facebook}{id},
            short_lived_access_token => $c->req->params->{access_token},
            fb_fields                => $ret->{facebook}
        });
    }

    $self->status_ok( $c, entity => $ret );
}


1;
