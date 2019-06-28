-- Deploy goiardi_postgres:sandboxes_insert_on_conflict to pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.merge_sandboxes(m_sbox_id varchar(32), m_creation_time timestamp with time zone, m_checksums jsonb, m_completed boolean);

CREATE OR REPLACE FUNCTION goiardi.merge_sandboxes(m_sbox_id varchar(32), m_creation_time timestamp with time zone, m_checksums jsonb, m_completed boolean, m_organization_id bigint) RETURNS VOID AS
$$
BEGIN
    INSERT INTO goiardi.sandboxes (sbox_id, creation_time, checksums, completed, organization_id) 
        VALUES (m_sbox_id, m_creation_time, m_checksums, m_completed, m_organization_id)
        ON CONFLICT(organization_id, sbox_id)
        DO UPDATE SET 
            checksums = m_checksums, 
            completed = m_completed;
END;
$$
LANGUAGE plpgsql;

COMMIT;
