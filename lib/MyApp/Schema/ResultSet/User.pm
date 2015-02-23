package MyApp::Schema::ResultSet::User;
use namespace::autoclean;

use utf8;
use Moose;
extends 'DBIx::Class::ResultSet';
with 'MyApp::Role::Verification';
with 'MyApp::Role::Verification::TransactionalActions::DBIC';
with 'MyApp::Schema::Role::InflateAsHashRef';

use Data::Verifier;
use MooseX::Types::Email qw/EmailAddress/;

sub verifiers_specs {
    my $self = shift;
    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {

                name => {
                    required => 1,
                    type     => 'Str',
                },

                password => {
                    required => 0,
                    type     => 'Str',
                },

                role => {
                    required => 1,
                    type     => 'Str',
                },

                email => {
                    required   => 1,
                    type       => EmailAddress,
                    post_check => sub {
                        my $r = shift;
                        return 0 if ( $self->find( { email => $r->get_value('email') } ) );
                        return 1;
                      }
                },


                is_facebook => {
                    required => 0,
                    type     => 'Bool',
                },
                fb_clientid => {
                    required => 0,
                    type     => 'Int',
                },
                fb_short_lived_access_token => {
                    required => 0,
                    type     => 'Str',
                },
                fb_fields => {
                    required => 0,
                    type     => 'Str',
                },
            },
        ),

        login => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                email => {
                    required   => 1,
                    type       => EmailAddress,
                    post_check => sub {
                        my $r = shift;
                        return defined $self->find( { email => $r->get_value('email') } );
                      }
                },
                password => {
                    required => 1,
                    type     => 'Str',
                },
            }
        ),

    };
}

sub action_specs {
    my $self = shift;
    return {
        login => sub { 1 },

        create => sub {
            my %values = shift->valid_values;
            delete $values{password_confirm};
            my $is_facebook = delete $values{is_facebook};

            my $password = delete $values{password};

            die \['password', 'missing']
                if !$password && !$is_facebook;

            my $role = delete $values{role};

            $values{password} = $password ? $password : 'empty';

            my $types = {
                'user' => 'user',
                'superadmin' => 'superadmin'
            };
            $values{type} = $role && exists $types->{$role} ? $types->{$role} : 'unknown';

            my $user = $self->create(
                \%values
            );

            if ($role) {
                $user->set_roles( { name => $role } );
            }

            return $user;
          }

    };
}

1;

