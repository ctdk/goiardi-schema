-- Revert goiardi_postgres:environments_insert_on_conflict from pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.merge_environments(m_name text, m_description text, m_default_attr jsonb, m_override_attr jsonb, m_cookbook_vers jsonb, m_organization_id bigint);

CREATE OR REPLACE FUNCTION goiardi.merge_environments(m_name text, m_description text, m_default_attr jsonb, m_override_attr jsonb, m_cookbook_vers jsonb) RETURNS VOID AS
$$
BEGIN
    LOOP
        -- first try to update the key
	UPDATE goiardi.environments SET description = m_description, default_attr = m_default_attr, override_attr = m_override_attr, cookbook_vers = m_cookbook_vers, updated_at = NOW() WHERE name = m_name;
	IF found THEN
		RETURN;
	END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
	    INSERT INTO goiardi.environments (name, description, default_attr, override_attr, cookbook_vers, created_at, updated_at) VALUES (m_name, m_description, m_default_attr, m_override_attr, m_cookbook_vers, NOW(), NOW());
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

COMMIT;
