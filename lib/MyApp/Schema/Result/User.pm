use utf8;
package MyApp::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApp::Schema::Result::User

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'user_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 email

  data_type: 'text'
  is_nullable: 0

=head2 active

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 password

  data_type: 'text'
  is_nullable: 0

=head2 created_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 fb_clientid

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 fb_short_lived_access_token

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 fb_long_lived_access_token

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 fb_fields

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "user_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "email",
  { data_type => "text", is_nullable => 0 },
  "active",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "password",
  { data_type => "text", is_nullable => 0 },
  "created_by",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "fb_clientid",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "fb_short_lived_access_token",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "fb_long_lived_access_token",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "fb_fields",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<user_email_key>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("user_email_key", ["email"]);

=head1 RELATIONS

=head2 created_by

Type: belongs_to

Related object: L<MyApp::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "created_by",
  "MyApp::Schema::Result::User",
  { id => "created_by" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 user_roles

Type: has_many

Related object: L<MyApp::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "MyApp::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_sessions

Type: has_many

Related object: L<MyApp::Schema::Result::UserSession>

=cut

__PACKAGE__->has_many(
  "user_sessions",
  "MyApp::Schema::Result::UserSession",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users

Type: has_many

Related object: L<MyApp::Schema::Result::User>

=cut

__PACKAGE__->has_many(
  "users",
  "MyApp::Schema::Result::User",
  { "foreign.created_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-02-23 13:14:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZtN18jmwMARFFID0m7Rspg

__PACKAGE__->many_to_many( roles => user_roles => 'role' );

__PACKAGE__->remove_column('password');
__PACKAGE__->add_column(
    password => {
        data_type        => "text",
        passphrase       => 'crypt',
        passphrase_class => 'BlowfishCrypt',
        passphrase_args  => {
            cost        => 8,
            salt_random => 1,
        },
        passphrase_check_method => 'check_password',
        is_nullable             => 0
    },
);

__PACKAGE__->has_many(
    "sessions",
    "MyApp::Schema::Result::UserSession",
    { "foreign.user_id" => "self.id" },
    { cascade_copy      => 0, cascade_delete => 0 },
);


with 'MyApp::Role::Verification';
with 'MyApp::Role::Verification::TransactionalActions::DBIC';
with 'MyApp::Schema::Role::ResultsetFind';

use Data::Verifier;
use MooseX::Types::Email qw/EmailAddress/;
use JSON::MaybeXS;


sub verifiers_specs {
    my $self = shift;
    return {

        update => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                name => {
                    required => 0,
                    type     => 'Str',
                },

                role => {
                    required => 0,
                    type     => 'Str',
                },
                email => {
                    required   => 0,
                    type       => EmailAddress,
                    post_check => sub {
                        my $r = shift;
                        return 1 if $self->email eq $r->get_value('email');

                        return 0 if $self->resultset_find( { email => $r->get_value('email') } );

                        return 1;
                      }
                },
                password => {
                    required => 0,
                    type     => 'Str',
                },

            },
        ),


    };
}

sub action_specs {
    my $self = shift;
    return {
        update => sub {
            my %values = shift->valid_values;

            not defined $values{$_} and delete $values{$_} for keys %values;

            my $new_role = delete $values{role};

            my $user = $self->update( \%values );
            $user->set_roles( { name => $new_role } ) if $new_role;
            return $user;
        },

    };
}
use Crypt::PRNG qw/random_bytes_hex/;

sub new_session {
    my $self = shift;
    my $ip   = shift;
    my $item = $self->sessions->create(
        {
            api_key      => random_bytes_hex(22),
            valid_for_ip => $ip
        }
    );

    $self->discard_changes;

    my %attrs = map { $_ => $self->$_ } qw/id name email type/;
    $attrs{api_key} = $item->api_key;
    $attrs{roles} = [ map { $_->name } $self->roles ];
    $attrs{has_password} = $self->has_password;
    $attrs{created_at} = $self->created_at->datetime;

    return \%attrs;
}

sub setup_facebook {
    my ($self, $conf) = @_;

    if ($conf->{short_lived_access_token}){
        $self->fb_short_lived_access_token($conf->{short_lived_access_token});
        # todo, push numa fila para gerar o long_lived_access_token
    }

    $self->fb_clientid($conf->{clientid})
        if ($conf->{clientid});

    $self->fb_fields(eval{encode_json $conf->{fb_fields}} or "invalid object: $@")
        if ($conf->{fb_fields});

    $self->update;
}

sub has_password {
    shift->password ne 'empty';
}

sub set_empty_password {
    shift->password('empty');
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
