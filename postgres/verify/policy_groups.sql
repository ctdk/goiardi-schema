-- Verify goiardi_postgres:policy_groups on pg

BEGIN;

SELECT id, name, organization_id, created_at, updated_at FROM goiardi.policy_groups WHERE FALSE;

SELECT id, policy_id, pg_id, created_at, updated_at FROM goiardi.policy_groups_to_policies WHERE FALSE;

-- XXX Add verifications here.

ROLLBACK;
