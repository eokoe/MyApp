package MyApp::Schema::ResultSet::UserToken;
use namespace::autoclean;

use utf8;
use Moose;
extends qw|DBIx::Class::ResultSet|;
with qw|
    MyApp::Role::Verification
    MyApp::Role::Verification::TransactionalActions::DBIC
    MyApp::Schema::Role::InflateAsHashRef
    |;

use Data::Verifier;
use MyApp::Types qw|MobileNumber|;
use Crypt::PRNG qw/random_bytes_hex random_string_from/;

sub verifiers_specs {
    my $self = shift;
    return {
        create => Data::Verifier->new(
            filters => [qw|trim|],
            profile =>
                {mobile_number => {required => 1, type => MobileNumber,}}
        ),
        check => Data::Verifier->new(
            filters => [qw|trim|],
            profile => {
                mobile_number => {required => 1, type => MobileNumber,},
                test_token    => {required => 1, type => 'Str'}
            }
        ),
        authenticate => Data::Verifier->new( filters => [qw|trim|],
            profile => {
                mobile_number => {required => 1, type => MobileNumber,},
                auth_token    => {required => 1, type => 'Str'}
            }
        )
    };
}

sub action_specs {
    my $self = shift;
    return {
        create => sub {
            my %values = shift->valid_values;
            return $self->create({
                    %values,
                    test_token => random_string_from("0123456789", 4),
                }
            );
        },
        check => sub {
            my %values = shift->valid_values;
            return $self->search(\%values)->count
                ? $self->create(
                {%values, auth_token => random_bytes_hex(22)})
                : {status => 'error'};
        },
        authenticate => sub {
            my %values = shift->valid_values;
            return $self->search(\%values)->count
                ? {status => 'ok'}
                : {status => 'error'};
            }
    };
}

1;
