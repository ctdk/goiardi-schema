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
	group_id bigint NOT NULL,
	user_id bigint NOT NULL,
	organization_id bigint NOT NULL,
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
	group_id bigint NOT NULL,
	client_id bigint NOT NULL,
	organization_id bigint NOT NULL,
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
	group_id bigint NOT NULL,
	member_group_id bigint NOT NULL,
	organization_id bigint NOT NULL,
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
	RAISE EXCEPTION 'Group % already exists, cannot rename %', new_name, old_name;
END;
$$
LANGUAGE plpgsql;
-- end rename groups

-- insert/update function
CREATE OR REPLACE FUNCTION goiardi.merge_groups(m_name text, m_organization_id bigint, m_actor_users bigint[], m_actor_clients bigint[], m_groups bigint[]) RETURNS BIGINT AS
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
	IF array_length(m_actor_clients, 1) > 0 THEN
		EXECUTE format('INSERT INTO goiardi.group_actor_clients
			(client_id, group_id, organization_id, created_at, updated_at)
			SELECT DISTINCT cid, %L::bigint ggid, %L::bigint gorgid, NOW() c, NOW() u
			FROM unnest($1) cid
			ON CONFLICT (group_id, client_id, organization_id)
				DO UPDATE SET updated_at = NOW()', g_id, m_organization_id
		) USING m_actor_clients; 
	END IF;

	-- users
	DELETE FROM goiardi.group_actor_users WHERE group_id = g_id AND organization_id = m_organization_id AND NOT (user_id = any(m_actor_users));
	IF array_length(m_actor_users, 1) > 0 THEN
		EXECUTE format('INSERT INTO goiardi.group_actor_users
			(user_id, group_id, organization_id, created_at, updated_at)
			SELECT DISTINCT uid, %L::bigint ggid, %L::bigint gorgid, NOW() c, NOW() u
			FROM unnest($1) uid
			ON CONFLICT (group_id, user_id, organization_id)
				DO UPDATE SET updated_at = NOW()', g_id, m_organization_id
		) USING m_actor_users;
	END IF;

	-- groups
	DELETE FROM goiardi.group_groups WHERE group_id = g_id AND organization_id = m_organization_id AND NOT (member_group_id = any(m_groups));
	IF array_length(m_groups, 1) > 0 THEN
		EXECUTE format('INSERT INTO goiardi.group_groups
			(member_group_id, group_id, organization_id, created_at, updated_at)
			SELECT DISTINCT mgid, %L::bigint ggid, %L::bigint gorgid, NOW() c, NOW() u
			FROM unnest($1) mgid
			ON CONFLICT (group_id, member_group_id, organization_id)
				DO UPDATE SET updated_at = NOW()', g_id, m_organization_id
		) USING m_groups;
	END IF;

	RETURN g_id;
END;
$$
LANGUAGE plpgsql;
-- end the insert/update function

COMMIT;
