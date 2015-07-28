-- Deploy myapp:0004-user_token to pg
-- requires: 0003-facebook_data_on_db

BEGIN;

-- Table: user_token

-- DROP TABLE user_token;

CREATE TABLE user_token
(
  mobile_number numeric(14,0),
  test_token text,
  auth_token text
)
WITH (
  OIDS=FALSE
);

COMMIT;
