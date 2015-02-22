-- Deploy 0001-new-role

BEGIN;


INSERT INTO "user" ("id", "name", "email", "active", "created_at", "password", "created_by", "type")
VALUES (-1, 'web-api', 'web-api', true, now(), 'disabled', NULL, 'web-api');

insert into "role" (id,name) values(-1, 'web_api');
insert into "user_role" (role_id, user_id) values(-1,-1);


insert into user_session(user_id, api_key, valid_for_ip, valid_until)
values (-1, 'please change that key', '127.0.0.1', now()+'5 years');


COMMIT;
