
This is sample app using `CatalystX::Eta::` Roles as CRUD.

Deps with binary deps:

    DBD::Pg         - PostgreSQL
    App::Sqitch

How to test this app:

    $ cpanm --installdeps .

    $ createdb myapp_tesing

    Open the file sqitch.conf and configure the target database:

    [target "local"]
    uri = db:pg://postgres:in-postgres-we-trust@127.0.0.1:5432/myapp_dev

    [target "local2"]
    uri = db:pg://postgres:in-postgres-we-trust@127.0.0.1:5432/myapp_tesing

    [target "prod"]
    uri = db:pg://postgres:in-postgres-we-trust@127.0.0.1:5432/myapp_prod

    $ sqitch deploy -t local2

    $ cp myapp.conf myapp_local.conf

    open myapp_local.conf and configure <connect_info> and <testing_connect_info>

    $ prove -I ../catalystX-eta/lib/ -lvr t/

    or faster:

    $ forkprove -I ../catalystX-eta/lib/ -lvr -j8 -MMyApp t/

If you have `forkprove` installed:

    forkprove -I ../catalystX-eta/lib/ -MMyApp -j8 -lvr t/

    # you may want change -j8 to something else!

To tidy all code:

    tidyall -a

