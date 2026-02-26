-- Verify goiardi_postgres:client_user_keys on pg

BEGIN;

SELECT id, client_id, name, public_key, expiration_date, created_at, updated_at FROM goairdi.client_keys WHERE false;

SELECT id, user_id, name, public_key, expiration_date, created_at, updated_at FROM goairdi.user_keys WHERE false;

ROLLBACK;
