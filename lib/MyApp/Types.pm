package MyApp::Types;

use MooseX::Types -declare => [
    qw( DataStr
        MobileNumber
        )
];
use MooseX::Types::Moose qw(ArrayRef HashRef Int CodeRef Str ScalarRef);
use Moose::Util::TypeConstraints;
use DateTime::Format::Pg;

#DataStr
subtype DataStr, as Str, where {
    eval { DateTime::Format::Pg->parse_datetime($_)->datetime };
    return $@ eq '';
}, message { "invalid date [$_]" };

coerce DataStr, from Str, via {
    DateTime::Format::Pg->parse_datetime($_)->datetime;
};


#Mobile number
subtype MobileNumber, as Int, where {
    return $_ =~ m#(\d{13,14})# ? 1 : 0;
}, message {
    "$_ mobile number invalido";
};

1;
