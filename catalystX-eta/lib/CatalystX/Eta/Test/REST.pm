package CatalystX::Eta::Test::REST;

use strict;
use warnings;
use utf8;
use URI;
use JSON::XS;
use HTTP::Request::Common qw(GET POST DELETE HEAD);

use Test::More;

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

my $stash = {};
my $list_urls = {};

our $ctx_request = undef;

sub catalyst_request {
    $ctx_request ? $ctx_request->(@_) : die 'ctx_request not defined.';
}

sub rest_put {
    my $url  = shift;
    my $data = pop;
    my %conf = @_;

    &rest_post( $url, code => ( exists $conf{is_fail} ? 400 : 202 ), method => 'PUT', %conf, $data );
}

sub rest_delete {
    my $url  = shift;
    my %conf = @_;

    &rest_post( $url, code => 204, method => 'DELETE', %conf, [] );
}

sub rest_post {
    my $url  = shift;
    my $data = pop;
    my %conf = @_;
    $url = join '/', @$url if ref $url eq 'ARRAY';

    $conf{code} ||= exists $conf{is_fail} ? 400 : 201;

    my $name = $conf{name} || "POST $url";
    my $stashkey = exists $conf{stash} ? $conf{stash} : undef;

    my $req;

    if ( !exists $conf{files} ) {
        $req = POST $url, $data;
    }
    else {

        $conf{files}{$_} = [ $conf{files}{$_} ] for keys %{ $conf{files} };

        $req = POST $url,
          'Content-Type' => 'form-data',
          Content        => [ @$data, %{ $conf{files} } ];
    }

    $req->method( $conf{method} ) if exists $conf{method};

    my ( $res, $c ) = catalyst_request($req);

    if ( exists $conf{is_fail} ) {
        if ( !ok( !$res->is_success, $name . ' is_fail' ) ) {
            eval('use Data::Printer; p $res');
        }
    }
    else {

        if ( !ok( $res->is_success, $name . ' is_success' ) ) {
            eval('use Data::Printer; p $res');
        }
    }
    is( $res->code, $conf{code}, $name . ' status code is ' . $conf{code} );

    return 'deleted!!' if $conf{code} == 204;

    if ( exists $conf{is_fail} ) {
        return undef if $res->is_success;
    }
    else {
        return undef unless $res->is_success;
    }

    my $obj = eval { decode_json( $res->content ) };
    fail($@) if $@;

    if ( $conf{code} == 201 ) {
        like( $obj->{id}, qr/^[0-9]+$/, 'id ' . $obj->{id} . ' looks int' );

        $stash->{ $stashkey . '.id' } = $obj->{id} if $stashkey;
    }

    my $item_url = $res->header('Location');

    if ($stashkey) {
        $stash->{$stashkey} = $obj;
        $stash->{ $stashkey . '.url' } = $item_url;
    }

    if ( $stashkey && $conf{code} == 201 ) {

        &rest_reload($stashkey);
    }

    if ( $stashkey && exists $conf{list} ) {

        my ( $res, $c ) = catalyst_request( GET $url );
        ok( $res->is_success, 'GET ' . $url . ' is_success' );
        is( $res->code, 200, 'GET ' . $url . ' status code is 200' );

        my $obj3 = eval { decode_json( $res->content ) };
        fail($@) if $@;

        $stash->{ $stashkey . '.list' } = $obj3;

        $list_urls->{$stashkey} = $url;
    }

    return $obj;
}

sub dumpstash {
    eval('use Data::Printer; p $stash;');
}

sub rest_reload {
    my ( $stashkey, $exp_code ) = @_;

    $exp_code ||= 200;

    my $item_url = $stash->{ $stashkey . '.url' };

    my ( $res, $c ) = catalyst_request( GET $item_url );

    if ( $exp_code == 200 ) {
        if ( !ok( $res->is_success, 'GET ' . $item_url . ' is_success' ) ) {
            eval('use Data::Printer; p $res');
        }
        is( $res->code, 200, 'GET ' . $item_url . ' status code is 200' );

        my $obj = eval { decode_json( $res->content ) };
        fail($@) if $@;

        $stash->{ $stashkey . '.get' } = $obj;
    }
    elsif ( $exp_code == 404 ) {

        ok( !$res->is_success, 'GET ' . $item_url . ' does not exists' );
        is( $res->code, 404, 'GET ' . $item_url . ' status code is 404' );

        delete $stash->{ $stashkey . '.get' };
        delete $stash->{ $stashkey . '.id' };
        delete $stash->{ $stashkey . '.url' };
        delete $stash->{ $stashkey . '.list' };
        delete $stash->{$stashkey};

    }
    else {
        die "not supported $exp_code code!";
    }

    return $res;
}

sub rest_get {
    my ( $url, $exp_code, $params ) = @_;

    $url = join '/', @$url if ref $url eq 'ARRAY';

    $params ||= {};

    my $uri = URI->new($url);
    $uri->query_form(%$params);
    $url = $uri->as_string;

    $exp_code ||= 200;

    my ( $res, $c ) = catalyst_request( GET $url );

    if ( $exp_code == 200 ) {
        ok( $res->is_success, 'GET ' . $url . ' is_success' );
        is( $res->code, 200, 'GET ' . $url . ' status code is 200' );
    }
    else {
        is( $res->code, $exp_code, 'GET ' . $url . ' status code is ' . $exp_code );
    }

    my $obj = eval { decode_json( $res->content ) };
    fail($@) if $@;

    return $obj;
}

sub stash_test($&) {
    my ( $staname, $sub ) = @_;

    $sub->( $stash->{$staname} );
}

sub stash ($) {
    my ($key) = @_;
    return $stash->{$key};
}

sub rest_reload_list {
    my ($key) = @_;
    my $list = rest_get $list_urls->{$key};

    $stash->{ $key . '.list' } = $list;
    return $list;
}

1;
