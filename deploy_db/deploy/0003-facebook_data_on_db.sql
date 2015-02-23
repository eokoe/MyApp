-- Deploy 0003-facebook_data_on_db
-- requires: 0002-facebook-auth

BEGIN;

alter table "user" add column fb_fields varchar;

COMMIT;
