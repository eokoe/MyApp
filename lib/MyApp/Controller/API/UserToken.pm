package MyApp::Controller::API::UserToken;

use Moose;
use JSON::XS;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub base : Chained('/api/base') : PathPart('mobile-tokens') : CaptureArgs(0)
{
    my $self = shift;
    my $c    = shift;
    $c->stash->{collection} = $c->model('DB::UserToken');
}

sub create : Chained('base') : PathPart('create') : Args(0) :
    ActionClass('REST') {
}

sub create_POST {
    my ($self, $c) = @_;
    my $row = $c->stash->{collection}
        ->execute($c, for => 'create', with => $c->req->params,);
    $self->status_accepted($c, entity => {status => 'ok'});
}

sub check : Chained('base') : PathPart('check') : Args(0) :
    ActionClass('REST') {
}

sub check_POST {
    my ($self, $c) = @_;
    my $row = $c->stash->{collection}
        ->execute($c, for => 'check', with => $c->req->params );

    #
    # verificar com RenatoCRON se tem um jeito padrao pra validra a parte abaixo
    #

    ($row && $row->{status} && $row->{status} eq 'error')
        ? $self->status_not_found($c,
        message => 'item not found' )
        : $self->status_accepted($c,
        entity => {auth_token => $row->auth_token});
}

sub authenticate : Chained('base') : PathPart('authenticate') : Args(0) :
    ActionClass('REST') {
}

sub authenticate_POST {
    my ($self, $c) = @_;
    my $row = $c->stash->{collection}
        ->execute($c, for => 'authenticate', with => $c->req->params );
    ($row->{status} eq 'ok')
        ? $self->status_accepted( $c, entity => { status => 'ok' } )
        : $self->status_not_found( $c, message => 'could not authenticate mobilenumber with code' )
}

1;
