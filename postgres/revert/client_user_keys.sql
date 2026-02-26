-- Revert goiardi_postgres:client_user_keys from pg

BEGIN;

DROP TABLE goiardi.user_keys;
DROP TABLE goiardi.client_keys;

COMMIT;
