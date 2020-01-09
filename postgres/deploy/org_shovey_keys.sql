-- Deploy goiardi_postgres:org_shovey_keys to pg

BEGIN;

ALTER TABLE goiardi.organizations ADD COLUMN shovey_key TEXT DEFAULT NULL;

DROP FUNCTION goiardi.merge_orgs(m_name text, m_description text, m_guid UUID, m_uuid bytea);

CREATE OR REPLACE FUNCTION goiardi.merge_orgs(m_name text, m_description text, m_guid UUID, m_uuid bytea, m_shovey_key text) RETURNS BIGINT AS
$$
DECLARE
    org_id BIGINT;
BEGIN
    INSERT INTO goiardi.organizations (
        name,
        description,
        guid,
        uuid,
	shovey_key,
        created_at,
        updated_at
    ) 
        VALUES (
            m_name,
            m_description,
            m_guid,
            m_uuid,
            m_shovey_key,
            NOW(),
            NOW()
        )
        ON CONFLICT(name)
            DO UPDATE SET
                description = m_description,
                guid = m_guid,
                uuid = m_uuid,
		shovey_key = m_shovey_key,
                updated_at = NOW()
	RETURNING id INTO org_id;
	RETURN org_id;
END;
$$
LANGUAGE plpgsql;


COMMIT;
