package MyApp::TraitFor::Controller::ParamsAsArray;

use Moose::Role;

sub parmas_as_array {
    my ( $self, $splt, $itens ) = @_;

    my $out          = {};
    my $idx_visibles = {};

    foreach my $k ( keys %$itens ) {
        next unless $k =~ /^$splt:([^\:]+):([0-9]+)$/;

        my ( $name, $idx ) = ( $1, $2 );

        $out->{$idx}{$name} = $itens->{$k};
        $idx_visibles->{$idx}++;
    }

    # check if all items are with the same number of keys
    my $last;
    foreach my $idx ( keys %$idx_visibles ) {
        my $v = $idx_visibles->{$idx};
        $last = $v unless defined $last;
        die 'invalid "real_(name):(index)" parameters' if $last != $v;
    }

    my $array = [];
    foreach my $idx ( keys %$idx_visibles ) {

        my $item = {};
        foreach my $name ( keys %{ $out->{$idx} } ) {
            $item->{$name} = $out->{$idx}{$name};
        }
        push @$array, $item;
    }

    return $array;
}
