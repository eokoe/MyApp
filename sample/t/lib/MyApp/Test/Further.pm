package MyApp::Test::Further;

use strict;
use warnings;
use utf8;
use URI;

use Catalyst::Test q(MyApp);

# coloca use strict/warnings sozinho
sub import {
    strict->import;
    warnings->import;
}


use CatalystX::Eta::Test::REST;

# ugly hack
sub import {
    no strict 'refs';

    my $caller = caller;

    while (my ($name, $symbol) = each %{__PACKAGE__ . '::'}) {
        next if      $name eq 'BEGIN';   # don't export BEGIN blocks
        next if      $name eq 'import';  # don't export this sub
        next unless *{$symbol}{CODE};    # export subs only

        my $imported = $caller . '::' . $name;
        *{ $imported } = \*{ $symbol };
    }
}

# more ugly hacks
*CatalystX::Eta::Test::REST::catalyst_request = *ctx_request;


sub db_transaction (&) {
    my ($subref, $modelname) = @_;

    my $schema = MyApp->model( $modelname || 'DB');

    eval {
        $schema->txn_do(
            sub {
                $subref->($schema);
                die 'rollback';
            }
        );
    };

    die $@ unless $@ =~ /rollback/;

}

my $auth_user;
sub api_auth_as {
    my (%conf) = @_;

    $conf{user_id} ||= 1;
    $conf{roles}   ||= ['superadmin'];

    if ( !$auth_user ) {
        use Package::Stash;
        use MyApp::TestOnly::Mock::AuthUser;

        my $stashc = Package::Stash->new('Catalyst::Plugin::Authentication');
        $auth_user = MyApp::TestOnly::Mock::AuthUser->new;

        $stashc->add_symbol( '&user',  sub { return $auth_user } );
        $stashc->add_symbol( '&_user', sub { return $auth_user } );
    }

    $MyApp::TestOnly::Mock::AuthUser::_id    = $conf{user_id};
    @MyApp::TestOnly::Mock::AuthUser::_roles = @{ $conf{roles} };
}




1;
