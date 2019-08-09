-- Revert goiardi_postgres:user_insert_on_conflict from pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.merge_users(m_name text, m_displayname text, m_email text, m_admin boolean, m_public_key text, m_passwd varchar(128), m_salt bytea, m_first_name text, m_last_name text, m_recoveror bool, m_authz_id varchar(32));

DROP INDEX IF EXISTS goiardi.user_authz_id;

ALTER TABLE goiardi.users DROP COLUMN first_name;
ALTER TABLE goiardi.users DROP COLUMN last_name;
ALTER TABLE goiardi.users DROP COLUMN recoveror;
ALTER TABLE goiardi.users DROP COLUMN authz_id;

CREATE OR REPLACE FUNCTION goiardi.merge_users(m_name text, m_displayname text, m_email text, m_admin boolean, m_public_key text, m_passwd varchar(128), m_salt bytea, m_organization_id bigint) RETURNS VOID AS
$$
DECLARE
    c_id bigint;
    c_name text;
BEGIN
    SELECT id, name INTO c_id, c_name FROM goiardi.clients WHERE name = m_name AND organization_id = m_organization_id;
    IF FOUND THEN
        RAISE EXCEPTION 'a client with id % named % was found that would conflict with this client', c_id, c_name;
    END IF;
    IF m_email = '' THEN
        m_email := NULL;
    END IF;
    LOOP
        -- first try to update the key
        UPDATE goiardi.users SET name = m_name, displayname = m_displayname, email = m_email, admin = m_admin, public_key = m_public_key, passwd = m_passwd, salt = m_salt, updated_at = NOW() WHERE name = m_name;
        IF found THEN
            RETURN;
        END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
            INSERT INTO goiardi.users (name, displayname, email, admin, public_key, passwd, salt, created_at, updated_at) VALUES (m_name, m_displayname, m_email, m_admin, m_public_key, m_passwd, m_salt, NOW(), NOW());
            RETURN;
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

COMMIT;
