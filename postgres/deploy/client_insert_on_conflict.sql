-- Deploy goiardi_postgres:client_insert_on_conflict to pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.merge_clients(m_name text, m_nodename text, m_validator boolean, m_admin boolean, m_public_key text, m_certificate text);

CREATE OR REPLACE FUNCTION goiardi.merge_clients(m_name text, m_nodename text, m_validator boolean, m_admin boolean, m_public_key text, m_certificate text, m_organization_id bigint) RETURNS BIGINT AS
$$
DECLARE
    u_id bigint;
    u_name text;
    c_id bigint;
BEGIN
    SELECT id, name INTO u_id, u_name FROM goiardi.users WHERE name = m_name;
    IF FOUND THEN
        RAISE EXCEPTION 'a user with id % named % was found that would conflict with this client', u_id, u_name;
    END IF;

    INSERT INTO goiardi.clients (name, nodename, validator, admin, public_key, certificate, created_at, updated_at, organization_id)
        VALUES (m_name, m_nodename, m_validator, m_admin, m_public_key, m_certificate, NOW(), NOW(), m_organization_id)
        ON CONFLICT(organization_id, name)
            DO UPDATE SET 
                nodename = m_nodename, 
                validator = m_validator, 
                admin = m_admin,
                public_key = m_public_key,
                certificate = m_certificate,
                updated_at = NOW()
        RETURNING id INTO c_id;
        RETURN c_id;
END;
$$
LANGUAGE plpgsql;

COMMIT;
