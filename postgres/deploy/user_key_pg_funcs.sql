-- Deploy goiardi_postgres:user_key_pg_funcs to pg

BEGIN;

CREATE OR REPLACE FUNCTION goiardi.merge_user_keys(m_name text, m_public_key text, m_expiration_date timestamp, m_user_id bigint) RETURNS BIGINT AS
$$
DECLARE
    k_id bigint;
BEGIN
    INSERT INTO goiardi.user_keys(name, public_key, expiration_date, created_at, updated_at, user_id)
        VALUES(m_name, m_public_key, m_expiration_date, NOW(), NOW(), m_user_id)
        ON CONFLICT(user_id, name)
            DO UPDATE SET
                name = m_name,
                public_key = m_public_key,
                expiration_date = m_expiration_date,
                updated_at = NOW()
        RETURNING id INTO k_id;
        RETURN k_id;
END;
$$
LANGUAGE plpgsql;

COMMIT;
