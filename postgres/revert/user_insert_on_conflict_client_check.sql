-- Revert goiardi_postgres:user_insert_on_conflict_client_check from pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.merge_users(m_name text, m_displayname text, m_email text, m_admin boolean, m_public_key text, m_passwd varchar(128), m_salt bytea, m_first_name text, m_last_name text, m_recoveror bool, m_authz_id varchar(32));

CREATE OR REPLACE FUNCTION goiardi.merge_users(m_name text, m_displayname text, m_email text, m_admin boolean, m_public_key text, m_passwd varchar(128), m_salt bytea, m_first_name text, m_last_name text, m_recoveror bool, m_authz_id varchar(32)) RETURNS BIGINT AS
$$
DECLARE
    user_id BIGINT;
    c_id BIGINT;
    c_name TEXT;
BEGIN
    IF m_email = '' THEN
        m_email := NULL;
    END IF;
    IF m_first_name = '' THEN
        m_first_name := NULL;
    END IF;
    IF m_last_name = '' THEN
        m_last_name := NULL;
    END IF;
    IF m_authz_id = '' THEN
        m_authz_id := NULL;
    END IF;

    INSERT INTO goiardi.users (
        name,
        displayname,
        email,
        admin,
        public_key,
        passwd,
        salt,
        first_name,
        last_name,
        recoveror,
        authz_id,
        created_at,
        updated_at
    )
    VALUES (
        m_name,
        m_displayname,
        m_email,
        m_admin,
        m_public_key,
        m_passwd,
        m_salt,
        m_first_name,
        m_last_name,
        m_recoveror,
        m_authz_id,
        NOW(),
        NOW()
    )
    ON CONFLICT(name) -- can we also ON CONFLICT UPDATE on email, etc.?
        DO UPDATE SET
            name = m_name,
            displayname = m_displayname,
            email = m_email,
            admin = m_admin,
            public_key = m_public_key,
            passwd = m_passwd,
            salt = m_salt,
            first_name = m_first_name,
            last_name = m_last_name,
            recoveror = m_recoveror,
            authz_id = m_authz_id,
            updated_at = NOW()
    RETURNING id INTO user_id;
    RETURN user_id;
END;
$$
LANGUAGE plpgsql;

COMMIT;
