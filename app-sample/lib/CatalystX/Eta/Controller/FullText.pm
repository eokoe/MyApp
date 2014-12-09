package CatalystX::Eta::Controller::FullText;

use Moose::Role;
use CatalystX::Eta::FullTextWords;

sub BUILD {
    my ($self) = @_;

    my $search_ok = $self->config->{search_ok};

    $search_ok = {} if !$search_ok;

    $search_ok->{name}     = 'Str';
    $search_ok->{name_url} = 'Str';

    $self->config->{search_ok} = $search_ok;
}

around list_GET => sub {
    my $orig = shift;
    my $self = shift;

    my ($c) = @_;

    #print "      FullText::around list_GET \n";

    if ( exists $c->req->params->{full_text_words} && $c->req->params->{full_text_words} ) {
        my $limit = exists $c->req->params->{max_rows} ? $c->req->params->{max_rows} : 25;

        my ( $tswords, $methaf ) = CatalystX::Eta::FullTextWords->simplify( $c->req->params->{full_text_words}, 1 );

        $_ =~ s/[^A-Z0-9]//gio for @$tswords;
        $_ =~ s/[^A-Z]//go     for @$methaf;

        $methaf  = [ grep { $_ && $_ ne '' } @$methaf ];
        $tswords = [ grep { $_ && $_ ne '' } @$tswords ];

        if ( @$tswords > 0 ) {

            my $tsquery = ( '(' . ( join ' & ', map { "($_|$_:*)" } @$tswords ) . ')' )
              . ( @$methaf ? ' | (' . join( ' & ', @$methaf ) . ')' : '' );

            my $query_qt = "'$tsquery'::tsquery";
            $c->stash->{collection} = $c->stash->{collection}->search(
                {
                    'me.full_text_words' => \" \@\@ $query_qt"
                },
                {
                    order_by => \"ts_rank_cd( to_tsvector(me.name), $query_qt, 32) DESC",
                    rows     => $limit
                }
            );

        }
        else {
            $c->stash->{collection} = $c->stash->{collection}->search(
                {
                    'me.name' => $c->req->params->{full_text_words}
                },
                {
                    rows => $limit
                }
            );
        }
    }
    $self->$orig(@_);
};

1;

