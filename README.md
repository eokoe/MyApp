
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

    $ prove -lvr t/

    or faster, if you have `forkprove` installed:

    $ forkprove -lvr -j 8 -MMyApp t/


To tidy all code:

    tidyall -a

