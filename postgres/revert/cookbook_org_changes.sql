-- Revert goiardi_postgres:cookbook_org_changes from pg

BEGIN;

DROP INDEX IF EXISTS cb_organization_id;

DROP FUNCTION IF EXISTS goiardi.merge_cookbooks(m_name text, m_organization_id bigint);

CREATE OR REPLACE FUNCTION goiardi.merge_cookbooks(m_name text) RETURNS BIGINT AS
$$
DECLARE
    c_id BIGINT;
BEGIN
    LOOP
        -- first try to update the key
        UPDATE goiardi.cookbooks SET name = m_name, updated_at = NOW() WHERE name = m_name RETURNING id INTO c_id;
        IF found THEN
            RETURN c_id;
        END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
            INSERT INTO goiardi.cookbooks (name, created_at, updated_at) VALUES (m_name, NOW(), NOW()) RETURNING id INTO c_id;
            RETURN c_id;
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

COMMIT;
