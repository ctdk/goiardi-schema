-- Deploy goiardi_postgres:groups to pg

BEGIN;

-- What would be expected from the group model to be a single 'actors'
-- association table is split up into separate 'actor_users' and 'actor_clients'
-- tables, because they draw from different tables. The actors from these two
-- tables will be merged together by the code that retrieves this data from the
-- db, of course.


CREATE TABLE goiardi.groups (
	id bigserial,
	name text not null,
	organization_id bigint not null default 1,
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	PRIMARY KEY(id),
	UNIQUE(organization_id, name)
);

CREATE TABLE goiardi.group_actor_users (
	id bigserial,
	group_id bigint,
	user_id bigint,
	organization_id bigint,
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	PRIMARY KEY(id),
	UNIQUE(group_id, user_id, organization_id),
	FOREIGN KEY(user_id)
		REFERENCES goiardi.users(id)
		ON DELETE CASCADE,
	FOREIGN KEY(group_id)
		REFERENCES goiardi.groups(id)
		ON DELETE CASCADE
);

CREATE TABLE goiardi.group_actor_clients (
	id bigserial,
	group_id bigint,
	client_id bigint,
	organization_id bigint,
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	PRIMARY KEY(id),
	UNIQUE(group_id, client_id, organization_id),
	FOREIGN KEY(client_id)
		REFERENCES goiardi.clients(id)
		ON DELETE CASCADE,
	FOREIGN KEY(group_id)
		REFERENCES goiardi.groups(id)
		ON DELETE CASCADE
);

CREATE TABLE goiardi.group_groups (
	id bigserial,
	group_id bigint,
	member_group_id bigint,
	organization_id bigint,
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	PRIMARY KEY(id),
	UNIQUE(group_id, member_group_id, organization_id),
	FOREIGN KEY(member_group_id)
		REFERENCES goiardi.groups(id)
		ON DELETE CASCADE,
	FOREIGN KEY(group_id)
		REFERENCES goiardi.groups(id)
		ON DELETE CASCADE
);

-- Rename groups function

CREATE OR REPLACE FUNCTION goiardi.rename_group(old_name text, new_name text, m_organization_id int) RETURNS VOID AS
$$
BEGIN
	UPDATE goiardi.groups SET name = new_name, updated_at = NOW() WHERE name = old_name AND organization_id = m_organization_id;
EXCEPTION WHEN unique_violation THEN
	RAISE EXCEPTION 'Group % already exists, cannot rename %', old_name, new_name;
END;
$$
LANGUAGE plpgsql;
-- end rename groups

-- insert/update function
CREATE OR REPLACE FUNCTION goiardi.merge_groups(m_name text, m_organization_id bigint, m_actor_users bigint[], m_actor_clients bigint[], m_groups bigint[]) RETURNS VOID AS
$$
DECLARE
	g_id bigint;
BEGIN
	-- Do the INSERT ... ON CONFLICT thingy, also returning the id into
	-- g_id.

	INSERT INTO goiardi.groups
		(name, organization_id, created_at, updated_at)
		VALUES
		(m_name, m_organization_id, NOW(), NOW())
		ON CONFLICT (organization_id, name)
			-- Don't actually change the name or anything, since
			-- that's what the rename function's for. Just bump
			-- updated_at, since we want to reflect any updates to
			-- the member associations.
			DO UPDATE SET updated_at = NOW()
		RETURNING id INTO g_id;
	-- Delete any existing group associations before inserting the new ones

	-- clients
	DELETE FROM goiardi.group_actor_clients WHERE group_id = g_id AND organization_id = m_organization_id AND NOT (client_id = any(m_actor_clients));
	EXECUTE format('INSERT INTO goiardi.group_actor_clients
		(group_id, client_id, organization_id, created_at, updated_at)
		SELECT %L ggid, cid, %L gorgid, NOW() c, NOW() u
		FROM unnest($1) cid
		ON CONFLICT (group_id, client_id, organization_id)
			DO UPDATE SET updated_at = NOW()', g_id, m_organization_id, g_id, m_organization_id
	) USING m_actor_clients; 

	-- users
	DELETE FROM goiardi.group_actor_users WHERE group_id = g_id AND organization_id = m_organization_id AND NOT (user_id = any(m_actor_users));
	EXECUTE format('INSERT INTO goiardi.group_actor_users
		(group_id, user_id, organization_id, created_at, updated_at)
		SELECT %L ggid, uid, %L gorgid, NOW() c, NOW() u
		FROM unnest($1) uid
		ON CONFLICT (group_id, user_id, organization_id)
			DO UPDATE SET updated_at = NOW()', g_id, m_organization_id, g_id, m_organization_id
	) USING m_actor_users;

	-- groups
	DELETE FROM goiardi.group_groups WHERE group_id = g_id AND organization_id = m_organization_id AND NOT (member_group_id = any(m_groups));
	EXECUTE format('INSERT INTO goiardi.group_groups
		(group_id, member_group_id, organization_id, created_at, updated_at)
		SELECT %L ggid, mgid, %L gorgid, NOW() c, NOW() u
		FROM unnest($1) mgid
		ON CONFLICT (group_id, member_group_id, organization_id)
			DO UPDATE SET updated_at = NOW()', g_id, m_organization_id, g_id, m_organization_id
	) USING m_groups;

END;
$$
LANGUAGE plpgsql;
-- end the insert/update function

COMMIT;
