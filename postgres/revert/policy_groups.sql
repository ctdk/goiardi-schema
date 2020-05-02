-- Revert goiardi_postgres:policy_groups from pg

BEGIN;

DROP TRIGGER IF EXISTS goiardi_pg_policy_updated_time ON goiardi.policy_groups_to_policies;
DROP TRIGGER IF EXISTS goiardi_pg_policy_group_updated_time ON goiardi.policy_groups_to_policies;
DROP FUNCTION IF EXISTS goiardi.policy_group_updated_time();
DROP FUNCTION IF EXISTS goiardi.merge_policy_groups_to_policies(m_pg_id bigint, m_policy_id bigint, m_policy_rev_id bigint);
DROP FUNCTION IF EXISTS goiardi.merge_policy_groups(m_name text, m_organization_id bigint);
DROP INDEX IF EXISTS goiard.pg_revision_id;
DROP TABLE IF EXISTS goiardi.policy_groups_to_policies;
DROP TABLE IF EXISTS goiardi.policy_groups;

COMMIT;
