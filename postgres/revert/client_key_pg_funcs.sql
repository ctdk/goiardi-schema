-- Revert goiardi_postgres:client_key_pg_funcs from pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.merge_client_keys(m_name test, m_public_key text, m_expiration_date timestamp, m_client_id bigint);

COMMIT;
