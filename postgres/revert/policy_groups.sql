-- Revert goiardi_postgres:policy_groups from pg

BEGIN;

DROP TRIGGER IF EXISTS goiardi_pg_policy_updated_time ON goiardi.policy_groups_to_policies;
DROP TRIGGER IF EXISTS goiardi_pg_policy_group_updated_time ON goiardi.policy_groups_to_policies;
DROP FUNCTION IF EXISTS goiardi.policy_group_updated_time();
DROP INDEX IF EXISTS goiard.pg_revision_id;
DROP TABLE IF EXISTS goiardi.policy_groups_to_policies;
DROP TABLE IF EXISTS goiardi.policy_groups;

COMMIT;
