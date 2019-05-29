-- Deploy goiardi_postgres:org_new_columns to pg

BEGIN;

ALTER TABLE goiardi.organizations ADD COLUMN guid UUID DEFAULT NULL;
ALTER TABLE goiardi.organizations ADD COLUMN uuid bytea DEFAULT NULL;
ALTER TABLE goiardi.organizations ADD COLUMN full_name text;

DROP FUNCTION goiardi.merge_orgs(m_name text, m_description text);

CREATE OR REPLACE FUNCTION goiardi.merge_orgs(m_name text, m_full_name text, m_description text, m_guid UUID, m_uuid bytea) RETURNS VOID AS
$$
BEGIN
    LOOP
        -- first try to update the key
	UPDATE goiardi.organizations SET full_name = m_full_name, description = m_description, guid = m_guid, uuid = m_uuid, updated_at = NOW() WHERE name = m_name;
	IF found THEN
	    RETURN;
	END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
	    INSERT INTO goiardi.organizations (name, full_name, description, guid, uuid, created_at, updated_at) VALUES (m_name, m_full_name, m_description, m_guid, m_uuid, NOW(), NOW());
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

COMMIT;
