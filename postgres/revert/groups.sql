-- Revert goiardi_postgres:groups from pg

BEGIN;

DROP FUNCTION goiardi.merge_groups(m_name text, m_organization_id bigint, m_actor_users bigint[], m_actor_clients bigint[], m_groups bigint[]);
DROP FUNCTION goiardi.rename_group(old_name text, new_name text, m_organization_id int);

DROP TABLE goiardi.group_groups;
DROP TABLE goiardi.group_actor_clients;
DROP TABLE goiardi.group_actor_users;
DROP TABLE goiardi.groups;

COMMIT;
