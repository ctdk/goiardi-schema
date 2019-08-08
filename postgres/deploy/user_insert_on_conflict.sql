-- Deploy goiardi_postgres:user_insert_on_conflict to pg

BEGIN;

DROP FUNCTION goiardi.merge_users(m_name text, m_displayname text, m_email text, m_admin boolean, m_public_key text, m_passwd varchar(128), m_salt bytea, m_organization_id bigint);

ALTER TABLE goiardi.users ADD COLUMN first_name text DEFAULT NULL;
ALTER TABLE goiardi.users ADD COLUMN last_name text DEFAULT NULL;
ALTER TABLE goiardi.users ADD COLUMN recoverer bool DEFAULT FALSE; -- ?
ALTER TABLE goiardi.users ADD COLUMN authz_id varchar(32) DEFAULT NULL;

CREATE INDEX user_authz_id ON goiardi.users(authz_id);

-- There are still the external auth id and uid columns, but that's far enough
-- out from implementation that I'm not going to add them right now since I'm
-- not entirely certain what data type they should be.

-- In addition to the new columns, this should return the user id.

CREATE OR REPLACE FUNCTION goiardi.merge_users(m_name text, m_displayname text, m_email text, m_admin boolean, m_public_key text, m_passwd varchar(128), m_salt bytea, m_first_name text, m_last_name text, m_recoveror bool, m_authz_id varchar(32), m_organization_id bigint) RETURNS BIGINT AS
$$
DECLARE
    user_id BIGINT;
    c_id BIGINT;
    c_name TEXT;
BEGIN
    SELECT id, name INTO c_id, c_name FROM goiardi.clients WHERE name = m_name AND organization_id = m_organization_id;
    IF FOUND THEN
        RAISE EXCEPTION 'a client with id % named % was found that would conflict with this client', c_id, c_name;
    END IF;
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
