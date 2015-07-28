use utf8;
package MyApp::Schema::Result::UserToken;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApp::Schema::Result::UserToken

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

=head1 TABLE: C<user_token>

=cut

__PACKAGE__->table("user_token");

=head1 ACCESSORS

=head2 mobile_number

  data_type: 'numeric'
  is_nullable: 1
  size: [14,0]

=head2 test_token

  data_type: 'text'
  is_nullable: 1

=head2 auth_token

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "mobile_number",
  { data_type => "numeric", is_nullable => 1, size => [14, 0] },
  "test_token",
  { data_type => "text", is_nullable => 1 },
  "auth_token",
  { data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-07-27 13:43:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ULx3LxZsf9yqTk3armWEgw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
