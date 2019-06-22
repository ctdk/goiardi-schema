-- Deploy goiardi_postgres:cookbook_org_changes to pg

BEGIN;

-- add an index for organization_id by itself on the cookbooks table
CREATE INDEX cb_organization_id ON goiardi.cookbooks(organization_id);

-- new cookbook merge function
DROP FUNCTION IF EXISTS goiardi.merge_cookbooks(m_name text);

CREATE OR REPLACE FUNCTION goiardi.merge_cookbooks(m_name text, m_organization_id bigint) RETURNS BIGINT AS
$$
DECLARE
    c_id BIGINT;
BEGIN
	-- remember to return c_id
	INSERT INTO goiardi.cookbooks (name, organization_id, created_at, updated_at)
		VALUES (m_name, m_organization_id, NOW(), NOW()) 
		ON CONFLICT(organization_id, name)
			DO UPDATE SET name = m_name, updated_at = NOW()
		RETURNING id INTO c_id;
        RETURN c_id;

END;
$$
LANGUAGE plpgsql;


COMMIT;
