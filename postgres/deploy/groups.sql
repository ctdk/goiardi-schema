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
	primary key(id),
	unique(organization_id, name)
);

CREATE TABLE goiardi.group_actor_users (
	id bigserial,
	group_id bigint,
	user_id bigint,
	organization_id bigint,
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	unique(group_id, user_id, organization_id)
);

CREATE TABLE goiardi.group_actor_clients (
	id bigserial,
	group_id bigint,
	client_id bigint,
	organization_id bigint,
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	unique(group_id, client_id, organization_id)
);

CREATE TABLE goiardi.group_groups (
	id bigserial,
	group_id bigint,
	member_group_id bigint,
	organization_id bigint,
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	unique(group_id, member_group_id, organization_id)
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
		(name, organization_id, actor_users, actor_clients, groups, created_at, updated_at)
		VALUES
		(m_name, m_organization_id, m_actor_users, m_actor_clients, m_groups, NOW(), NOW())
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
	INSERT INTO goiardi.group_actor_clients
		(group_id, client_id, organization_id, created_at, updated_at)
		SELECT g_id ggid, cid, m_organization_id gorgid, NOW() c, NOW() u
		FROM unnest(m_actor_clients) cid
		ON CONFLICT (group_id, client_id, organization_id)
			DO UPDATE SET updated_at = NOW(); 

	-- users
	DELETE FROM goiardi.group_actor_users WHERE group_id = g_id AND organization_id = m_organization_id AND NOT (user_id = any(m_actor_users));
	INSERT INTO goiardi.group_actor_users
		(group_id, user_id, organization_id, created_at, updated_at)
		SELECT g_id ggid, uid, m_organization_id gorgid, NOW() c, NOW() u
		FROM unnest(m_actor_users) uid
		ON CONFLICT (group_id, user_id, organization_id)
			DO UPDATE SET updated_at = NOW();

	-- groups
	DELETE FROM goiardi.group_groups WHERE group_id = g_id AND organization_id = m_organization_id AND NOT (member_group_id = any(m_groups));
	INSERT INTO goiardi.group_groups
		(group_id, member_group_id, organization_id, created_at, updated_at)
		SELECT g_id ggid, mgid, m_organization_id gorgid, NOW() c, NOW() u
		FROM unnest(m_groups) cid
		ON CONFLICT (group_id, member_group_id, organization_id)
			DO UPDATE SET updated_at = NOW();

END;
$$
LANGUAGE plpgsql;
-- end the insert/update function

COMMIT;
