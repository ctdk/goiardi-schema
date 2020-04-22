-- Revert goiardi_postgres:policy_groups from pg

BEGIN;

DROP TABLE IF EXISTS goiardi.policy_groups_to_policies;

DROP TABLE IF EXISTS goiardi.policy_groups;

COMMIT;
