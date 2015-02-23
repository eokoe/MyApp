package MyApp::Controller::API::User;

use Moose;
use JSON::XS;
use Facebook::OpenGraph;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',

    result      => 'DB::User',
    result_cond => { active => 1 },

    object_key => 'user',
    list_key   => 'users',

    update_roles => [qw/superadmin/],
    create_roles => [qw/superadmin web_api/],
    delete_roles => [qw/superadmin/],

    build_row => sub {
        my ( $r, $self, $c ) = @_;

        return {
            (
                (map { $_ => $r->$_ }
                  qw(
                  id name email type fb_clientid
                  )),
                  has_password => $r->has_password
            ),

        };
    },

    before_delete => sub {
        my ( $self, $c, $item ) = @_;

        $item->update({ active => 0 });

        return 0;
    },

    prepare_params_for_create => sub {
        my ( $self, $c, $params ) = @_;

        $self->validate_request_params(
            $c,
            access_token => {
                type     => 'Str',
                required => 0,
            },
        );

        if ($c->req->params->{access_token}){
            # todo cachear esse access_token para nao consultar mais de 1x
            my $fb = Facebook::OpenGraph->new({
                access_token => $params->{access_token}
            });

            my $facebook;
            eval {
                my $me = $fb->get('/me');
                my $pic = $fb->get('/me/picture?redirect=false&type=normal');

                delete $me->{verified};
                $facebook = {
                    %$me,
                    picture => $pic->{data}{url},
                };
            };
            die \['access_token', 'expired'] if $@ && $@ =~ /Session has expired/;
            die $@ if $@; # fatal error..

            $params->{is_facebook} = 1;

            $params->{fb_clientid}                 = $facebook->{id};
            $params->{fb_short_lived_access_token} = $params->{access_token};
            $params->{fb_fields}                = encode_json $facebook;
        }else{
            $self->validate_request_params(
                $c,
                password => {
                    type     => 'Str',
                    required => 1,
                },
            );
        }

        return $params;
    },

    search_ok => {

    }
);
with 'CatalystX::Eta::Controller::SimpleCRUD';

with 'CatalystX::Eta::Controller::TypesValidation';
sub base : Chained('/api/base') : PathPart('users') : CaptureArgs(0) { }

after 'base' => sub {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->stash->{collection}->search(
        {
            'me.id' => $c->user->id
        }
    ) if $c->check_any_user_role('user');

};

sub object : Chained('base') : PathPart('') : CaptureArgs(1) { }

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub result_GET { }

sub result_PUT { }

sub result_DELETE { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET { }

sub list_POST {
    my ($self, $c, $new_user) = @_;

    if ($c->req->params->{get_session}){
        $c->stash->{rest} = {
            id => $new_user->id,
            session => $new_user->new_session($c->req->address)
        };
    }
}



1;
