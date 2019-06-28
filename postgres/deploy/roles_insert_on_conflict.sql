-- Deploy goiardi_postgres:roles_insert_on_conflict to pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.merge_roles(m_name text, m_description text, m_run_list jsonb, m_env_run_lists jsonb, m_default_attr jsonb, m_override_attr jsonb);

CREATE OR REPLACE FUNCTION goiardi.merge_roles(m_name text, m_description text, m_run_list jsonb, m_env_run_lists jsonb, m_default_attr jsonb, m_override_attr jsonb, m_organization_id bigint) RETURNS VOID AS
$$
BEGIN
    INSERT INTO goiardi.roles (name, description, run_list, env_run_lists, default_attr, override_attr, created_at, updated_at, organization_id) 
        VALUES (m_name, m_description, m_run_list, m_env_run_lists, m_default_attr, m_override_attr, NOW(), NOW(), m_organization_id)
        ON CONFLICT(organization_id, name)
        DO UPDATE SET
            description = m_description
            run_list = m_run_list
            env_run_lists = m_env_run_lists
            default_attr = m_default_attr
            override_attr = m_override_attr
            updated_at = NOW();
END;
$$
LANGUAGE plpgsql;

COMMIT;
