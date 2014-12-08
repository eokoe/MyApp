package EtaMu::TraitFor::Controller::TypesValidation;

use Moose::Role;
use Moose::Util::TypeConstraints;

sub validate_request_params {
    my $self = shift;

    my ( $c, %fields ) = @_;

    foreach my $key ( keys %fields ) {

        my $me   = $fields{$key};
        my $type = $me->{type};
        my $val  = $c->req->params->{$key};

        $val = '' if !defined $val && $me->{clean_undef};

        if ( !defined $val && $me->{required} && !( $me->{undef_is_valid} && !defined $val ) ) {
            $self->status_bad_request( $c, message => "required param $key" );
            $c->detach;
        }

        if (
               defined $val
            && $val eq ''
            && (   $me->{empty_is_invalid}
                || $type eq 'Bool'
                || $type eq 'Int'
                || $type eq 'Num'
                || ref $type eq 'MooseX::Types::TypeDecorator' )
          ) {

            $self->status_bad_request( $c, message => "invalid empty param $key" );
            $c->detach;
        }

        next unless $val;

        my $cons = Moose::Util::TypeConstraints::find_or_parse_type_constraint($type);

        $self->status_bad_request( $c, message => "Unknown type constraint '$type'" ), $c->detach
          unless defined($cons);

        if ( !$cons->check($val) ) {
            $self->status_bad_request( $c, message => "invalid param $key" );
            $c->detach;
        }

    }

}

1;

