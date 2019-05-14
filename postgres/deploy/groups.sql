-- Deploy goiardi_postgres:groups to pg

BEGIN;

-- What would be expected from the group model to be a single 'actors' array is
-- split up into separate 'actor_users' and 'actor_clients' array columns,
-- because they draw from different tables. The actors from these two arrays
-- will be merged together by the code that retrieves this data from the db, of
-- course.

-- Note to self: foreign keys on actor_users, actor_clients, and groups?

CREATE TABLE goiardi.groups (
	id bigserial,
	name text not null,
	organization_id bigint not null default 1,
	actor_users bigint[],
	actor_clients bigint[],
	groups bigint[],
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	unique(organization_id, name)
);

-- Rename groups function
BEGIN;

CREATE OR REPLACE FUNCTION goiardi.rename_group(old_name text, new_name text, m_organization_id int) RETURNS VOID AS
$$
DECLARE
	c_id bigint;
	c_name text;
BEGIN
	BEGIN
		UPDATE goiardi.groups SET name = new_name, updated_at = NOW() WHERE name = old_name AND organization_id = m_organization_id;
	EXCEPTION WHEN unique_violation THEN
		RAISE EXCEPTION 'Group % already exists, cannot rename %', old_name, new_name;
	END;
END;
$$
LANGUAGE plpgsql;
-- end rename groups

-- insert/update function
CREATE OR REPLACE FUNCTION goiardi.merge_groups(m_name text, m_organization_id bigint, m_actor_users bigint[], m_actor_clients bigint[], m_groups bigint[]) RETURNS VOID AS
$$
BEGIN
    LOOP
        -- first try to update the key
	UPDATE goiardi.groups SET actor_users = m_actor_users, actor_clients = m_actor_clients, groups = m_groups, updated_at = NOW() WHERE name = m_name AND organization_id = m_organization_id;
	IF found THEN
	    RETURN;
	END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
	    INSERT INTO goiardi.groups (name, organization_id, actor_users, actor_clients, groups, created_at, updated_at) VALUES (m_name, m_organization_id, m_actor_users, m_actor_clients, m_groups, NOW(), NOW());
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;
-- end the insert/update function

COMMIT;
