-- Revert goiardi_postgres:org_new_columns from pg

BEGIN;

-- XXX Add DDLs here.
DROP FUNCTION goiardi.merge_orgs(m_name text, m_description text, m_guid UUID, m_uuid bytea);

CREATE OR REPLACE FUNCTION goiardi.merge_orgs(m_name text, m_description text) RETURNS VOID AS
$$
BEGIN
    LOOP
        -- first try to update the key
	UPDATE goiardi.organizations SET description = m_description, updated_at = NOW() WHERE name = m_name;
	IF found THEN
	    RETURN;
	END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
	    INSERT INTO goiardi.organizations (name, description, created_at, updated_at) VALUES (m_name, m_description, NOW(), NOW());
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

ALTER TABLE goiardi.organizations DROP COLUMN guid;
ALTER TABLE goiardi.organizations DROP COLUMN uuid;

COMMIT;
