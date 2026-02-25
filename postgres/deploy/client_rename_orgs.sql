-- Deploy goiardi_postgres:client_rename_orgs to pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.rename_client(old_name text, new_name text);

CREATE OR REPLACE FUNCTION goiardi.rename_client(old_name text, new_name text, m_organization_id int) RETURNS VOID AS
$$
DECLARE
	u_id bigint;
	u_name text;
BEGIN
	SELECT id, name INTO u_id, u_name FROM goiardi.users WHERE name = new_name;
	IF FOUND THEN
		RAISE EXCEPTION 'a user with id % named % was found that would conflict with this client', u_id, u_name;
	END IF;
	BEGIN
		UPDATE goiardi.clients SET name = new_name WHERE name = old_name AND organization_id = m_organization_id;
	EXCEPTION WHEN unique_violation THEN
		RAISE EXCEPTION 'Client % already exists, cannot rename %', old_name, new_name;
	END;
END;
$$
LANGUAGE plpgsql;

COMMIT;
