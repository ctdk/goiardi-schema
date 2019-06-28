-- Deploy goiardi_postgres:data_bags_insert_on_conflict to pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.merge_data_bags(m_name text);

CREATE OR REPLACE FUNCTION goiardi.merge_data_bags(m_name text, m_organization_id bigint) RETURNS BIGINT AS
$$
DECLARE
    db_id BIGINT;
BEGIN
    INSERT INTO goiardi.data_bags (name, created_at, updated_at, organization_id)
        VALUES (m_name, NOW(), NOW(), m_organization_id)
        ON CONFLICT(organization_id, name)
        DO UPDATE SET updated_at = NOW()
        RETURNING id INTO db_id;
    RETURN db_id;
END;
$$
LANGUAGE plpgsql;

COMMIT;
