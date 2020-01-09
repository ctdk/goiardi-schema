-- Revert goiardi_postgres:org_shovey_keys from pg

BEGIN;

DROP FUNCTION goiardi.merge_orgs(m_name text, m_description text, m_guid UUID, m_uuid bytea, m_shovey_key text);

CREATE OR REPLACE FUNCTION goiardi.merge_orgs(m_name text, m_description text, m_guid UUID, m_uuid bytea) RETURNS BIGINT AS
$$
DECLARE
    org_id BIGINT;
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
                updated_at = NOW()
	RETURNING id INTO org_id;
	RETURN org_id;
END;
$$
LANGUAGE plpgsql;

COMMIT;
