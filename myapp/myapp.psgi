use strict;
use warnings;
use lib 'lib';
use MyApp;

my $app = MyApp->apply_default_middlewares(MyApp->psgi_app);
$app;

