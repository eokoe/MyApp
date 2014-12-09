package CatalystX::Eta::FullTextWords;
use MooseX::Singleton;
use strict;
use utf8;

use Lingua::Stem::Pt;
use Text::Metaphone;
use Text::Unaccent::PurePerl qw(unac_string);

use Lingua::StopWords qw( getStopWords );

has _stopwords => (
    is      => 'ro',
    isa     => 'Any',
    lazy    => 1,
    default => sub { getStopWords('pt') }
);

sub simplify {
    my ( $self, $text, $list ) = @_;

    $text = lc unac_string($text);
    my $stopwords = $self->_stopwords;
    my @words = split /\s/, $text;

    my $stems = Lingua::Stem::Pt::stem(
        {
            -words  => \@words,
            -locale => 'pt',
        }
    );

    my @out = @{ [@words] };
    my @out2;

    for ( grep { !$stopwords->{$_} } @$stems ) {
        $_ =~ s/l$/u/o;
        $_ =~ s/ow$/o/o;

        my $mp = Metaphone($_);
        push @out2, $mp if $mp;
    }

    push @out, @out2 unless $list;
    return ( \@out, \@out2 ) if $list;

    return @out;
}

sub stem_items {
    my ( $self, $text, $list ) = @_;

    $text = lc unac_string($text);
    my $stopwords = $self->_stopwords;
    my @words = split /\s/, $text;

    my $stems = Lingua::Stem::Pt::stem(
        {
            -words  => \@words,
            -locale => 'pt',
        }
    );

    my @out = @{ [@words] };
    my @out2 = @$stems;

    push @out, @out2 unless $list;
    return ( \@out, \@out2 ) if $list;

    return @out;
}
1;
