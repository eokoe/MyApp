use utf8;
use FindBin qw|$Bin|;
use lib "$Bin/../../lib";

use MyApp::Test::Further;

api_auth_as user_id => 1;

my $mobile_number = 5511996070213;
my $received_test_token_via_SMS;
my $received_auth_token;
my $schema = MyApp->model('DB')->schema;

db_transaction {
    rest_post '/mobile-tokens/create',
        name  => 'usuario cadastra mobile number.',
        code  => 202,
        stash => 'mobile_token',
        [mobile_number => $mobile_number];

    stash_test 'mobile_token', sub {
        my ($res) = @_;
        ok $res->{status} eq 'ok', 'phone saved in db';
    };

    my $result = $schema->resultset('UserToken')->search({mobile_number=>$mobile_number});

    ok $result->count > 0, 'found at least 1 mobile phone saved in db' ;

    my $mobile_saved = $result->first;
    $received_test_token_via_SMS = $mobile_saved->test_token;

    rest_post '/mobile-tokens/check',
        name  => 'criar user token',
        code  => 202,
        stash => 'mobile_token',
        [mobile_number => $mobile_number, 
        test_token => $received_test_token_via_SMS,
        ];

    stash_test 'mobile_token', sub {
        my ($me) = @_;
        $received_auth_token = $me->{auth_token};
        ok length $received_auth_token == 44 , 'Auth token has correct length';
    };


    rest_post '/mobile-tokens/authenticate',
        name => 'authenticate mobile number and auth_token',
        code => 202,
        stash => 'mobile_token',
        [
            mobile_number => $mobile_number,
            auth_token    => $received_auth_token,
        ]
    ;

    stash_test 'mobile_token', sub {
        my ($me) = @_;
        my $user_token_input = $me->{test_token};
        is($me->{status}, 'ok', 'deu certo');
    };

    rest_post '/mobile-tokens/check',
        name    => 'testa com numero invalido',
        code    => 400,
        is_fail => 1,
        stash   => 'error',
        [mobile_number => '123',];
};

done_testing;
