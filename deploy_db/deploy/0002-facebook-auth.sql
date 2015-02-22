-- Deploy 0002-facebook-auth
-- requires: 0001-new-role

BEGIN;

alter table "user" add column fb_clientid varchar;
alter table "user" add column fb_short_lived_access_token varchar;
alter table "user" add column fb_long_lived_access_token varchar;

COMMIT;
