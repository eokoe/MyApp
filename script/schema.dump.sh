#!/usr/bin/env bash

if [ -d "script" ]; then
  cd script;
fi

perl myapp_create.pl model DB DBIC::Schema MyApp::Schema create=static components=TimeStamp,PassphraseColumn 'dbi:Pg:dbname=myapp_dev;host=localhost' postgres system quote_names=1 overwrite_modifications=1

cd ..;

rm lib/MyApp/Model/DB.pm.new;
rm t/model_DB.t.new;
