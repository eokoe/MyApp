Deps with binary deps:

    DBD::Pg         - PostgreSQL

How to test this app:

    cpanm --installdeps .

    createdb youapp_dev

    perl script/deploy.pl

    prove -lvr t/


If you have `forkprove` installed:

    forkprove -MMyApp -j8 -lvr t/

    # you may want change -j8 to something else!

To tidy all code:

    tidyall -a

