-- Deploy goiardi_postgres:nodes_insert_on_conflict to pg

BEGIN;

CREATE INDEX node_organization_id ON goiardi.nodes(organization_id);

DROP FUNCTION IF EXISTS goiardi.merge_nodes(m_name text, m_chef_environment text, m_run_list jsonb, m_automatic_attr jsonb, m_normal_attr jsonb, m_default_attr jsonb, m_override_attr jsonb);

CREATE OR REPLACE FUNCTION goiardi.merge_nodes(m_name text, m_chef_environment text, m_run_list jsonb, m_automatic_attr jsonb, m_normal_attr jsonb, m_default_attr jsonb, m_override_attr jsonb, m_organization_id bigint) RETURNS VOID AS
$$
BEGIN
    INSERT INTO goiardi.nodes (name, chef_environment, run_list, automatic_attr, normal_attr, default_attr, override_attr, created_at, updated_at, organization_id) 
        VALUES (m_name, m_chef_environment, m_run_list, m_automatic_attr, m_normal_attr, m_default_attr, m_override_attr, NOW(), NOW(), m_organization_id)
        ON CONFLICT(organization_id, name)
        DO UPDATE SET
            chef_environment = m_chef_environment
            run_list = m_run_list
            automatic_attr = m_automatic_attr
            normal_attr = m_normal_attr
            default_attr = m_default_attr
            override_attr = m_override_attr
            updated_at = NOW();
END;
$$
LANGUAGE plpgsql;

COMMIT;
