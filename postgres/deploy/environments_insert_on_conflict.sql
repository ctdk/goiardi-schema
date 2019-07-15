-- Deploy goiardi_postgres:environments_insert_on_conflict to pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.merge_environments(m_name text, m_description text, m_default_attr jsonb, m_override_attr jsonb, m_cookbook_vers jsonb);

CREATE OR REPLACE FUNCTION goiardi.merge_environments(m_name text, m_description text, m_default_attr jsonb, m_override_attr jsonb, m_cookbook_vers jsonb, m_organization_id bigint) RETURNS VOID AS
$$
BEGIN
    INSERT INTO goiardi.environments (name, description, default_attr, override_attr, cookbook_vers, created_at, updated_at, organization_id)
        VALUES (m_name, m_description, m_default_attr, m_override_attr, m_cookbook_vers, NOW(), NOW(), m_organization_id)
        ON CONFLICT(organization_id, name)
        DO UPDATE SET 
            description = m_description, 
            default_attr = m_default_attr, 
            override_attr = m_override_attr, 
            cookbook_vers = m_cookbook_vers, 
            updated_at = NOW();
END;
$$
LANGUAGE plpgsql;

COMMIT;
