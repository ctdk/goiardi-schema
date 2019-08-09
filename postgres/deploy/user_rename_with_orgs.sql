-- Deploy goiardi_postgres:user_rename_with_orgs to pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.rename_user(old_name text, new_name text, m_organization_id int);

CREATE OR REPLACE FUNCTION goiardi.rename_user(old_name text, new_name text) RETURNS VOID AS
$$
BEGIN
	SELECT true FROM goiardi.clients WHERE name = new_name;

	-- TODO: better error message that includes all clients, and all org
	-- names.
	IF FOUND THEN
		RAISE EXCEPTION 'one or more clients named % were found that would conflict with this user', new_name;
	END IF;
	BEGIN
		UPDATE goiardi.users SET name = new_name WHERE name = old_name;
	EXCEPTION WHEN unique_violation THEN
		RAISE EXCEPTION 'User % already exists, cannot rename %', old_name, new_name;
	END;
END;
$$
LANGUAGE plpgsql;

COMMIT;
