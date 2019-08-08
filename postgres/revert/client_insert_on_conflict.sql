-- Revert goiardi_postgres:client_insert_on_conflict from pg

-- Put this back the way it was.

BEGIN;

DROP INDEX IF EXISTS goiardi.client_authz_id;
ALTER TABLE goiardi.clients DROP COLUMN authz_id;

DROP FUNCTION IF EXISTS goiardi.merge_clients(m_name text, m_nodename text, m_validator boolean, m_admin boolean, m_public_key text, m_certificate text, m_authz_id varchar(32), m_organization_id bigint);

CREATE OR REPLACE FUNCTION goiardi.merge_clients(m_name text, m_nodename text, m_validator boolean, m_admin boolean, m_public_key text, m_certificate text) RETURNS VOID AS
$$
DECLARE
    u_id bigint;
    u_name text;
BEGIN
    SELECT id, name INTO u_id, u_name FROM goiardi.users WHERE name = m_name;
    IF FOUND THEN
        RAISE EXCEPTION 'a user with id % named % was found that would conflict with this client', u_id, u_name;
    END IF;
    LOOP
        -- first try to update the key
        UPDATE goiardi.clients SET name = m_name, nodename = m_nodename, validator = m_validator, admin = m_admin, public_key = m_public_key, certificate = m_certificate, updated_at = NOW() WHERE name = m_name;
        IF found THEN
            RETURN;
        END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
            INSERT INTO goiardi.clients (name, nodename, validator, admin, public_key, certificate, created_at, updated_at) VALUES (m_name, m_nodename, m_validator, m_admin, m_public_key, m_certificate, NOW(), NOW());
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

COMMIT;
