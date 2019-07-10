-- Deploy goiardi_postgres:org_new_columns to pg

BEGIN;

ALTER TABLE goiardi.organizations ADD COLUMN guid UUID DEFAULT NULL;
ALTER TABLE goiardi.organizations ADD COLUMN uuid bytea DEFAULT NULL;

UPDATE goiardi.organizations SET uuid = '\x00000000000000000000000000000000', guid = '00000000-0000-0000-0000-000000000000' WHERE uuid IS NULL AND guid IS NULL;

DROP FUNCTION goiardi.merge_orgs(m_name text, m_description text);

CREATE OR REPLACE FUNCTION goiardi.merge_orgs(m_name text, m_description text, m_guid UUID, m_uuid bytea) RETURNS VOID AS
$$
BEGIN
    INSERT INTO goiardi.organizations (
        name,
        description,
        guid,
        uuid,
        created_at,
        updated_at
    ) 
        VALUES (
            m_name,
            m_description,
            m_guid,
            m_uuid,
            NOW(),
            NOW()
        )
        ON CONFLICT(name)
            DO UPDATE SET
                description = m_description,
                guid = m_guid,
                uuid = m_uuid,
                updated_at = NOW();
END;
$$
LANGUAGE plpgsql;

COMMIT;
