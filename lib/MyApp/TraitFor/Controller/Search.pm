package MyApp::TraitFor::Controller::Search;

use Moose::Role;

around list_GET => sub {
    my $orig = shift;
    my $self = shift;

    # Talvez utilizar o Catalyst::TraitFor::Controller::DBIC::DoesPaging
    # mas eu nao gosto dele!
    $self->$orig(@_);
};

1;

