-- Deploy goiardi_postgres:client_key_pg_funcs to pg

BEGIN;

CREATE OR REPLACE FUNCTION goiardi.merge_client_keys(m_name text, m_public_key text, m_expiration_date timestamp, m_client_id bigint) RETURNS BIGINT AS
$$
DECLARE
    k_id bigint;
BEGIN
    INSERT INTO goiardi.client_keys(name, public_key, expiration_date, created_at, updated_at, client_id)
        VALUES(m_name, m_public_key, m_expiration_date, NOW(), NOW(), m_client_id)
        ON CONFLICT(client_id, name)
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
