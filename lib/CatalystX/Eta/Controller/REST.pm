package CatalystX::Eta::Controller::REST;

use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller::REST' }

sub end : Private {
    my ( $self, $c ) = @_;

    #... do things before Serializing ...

    my $code = $c->res->status;
    if ( $code == 200 and scalar( @{ $c->error } ) ) {
        $code = 500;    # We default to 500 for errors unless something else has been set.

        my ( $an_error, @other_errors ) = @{ $c->error };

        if ( ref $an_error eq 'DBIx::Class::Exception'
            && $an_error->{msg} =~ /duplicate key value violates unique constraint/ ) {
            $code = 400;

            $c->stash->{rest} =
              { error => 'You violated an unique constraint! Please verify your input fields and try again.' };
            $c->log->error( "Error: " . $an_error->{msg} );
        }
        elsif ( ref $an_error eq 'HASH' && $an_error->{error_code} ) {

            $code = $an_error->{error_code};

            $c->stash->{rest} =
              { error => $an_error->{message} };
            $c->log->error( "Error: " . $an_error->{message} );

        }
        else {

            $c->log->error( Dumper $an_error, @other_errors );

            $c->stash->{rest} = { error => 'Internal Server Error' };
        }

        $c->clear_errors;

        $c->res->status($code);
    }

    $c->forward('serialize');

    #... do things after Serializing ...
}

sub serialize : ActionClass('Serialize') { }

1;

