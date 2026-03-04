-- Revert goiardi_postgres:user_key_pg_funcs from pg

BEGIN;

DROP FUNCTION goiardi.merge_user_keys(m_name text, m_public_key text, m_expiration_date timestamp, m_user_id bigint);

COMMIT;
