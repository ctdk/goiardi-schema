-- Verify goiardi_postgres:policy_revisions on pg

BEGIN;

SELECT id, policy_id, revision_id, run_list, cookbook_locks, default_attr, override_attr, solution_dependencies FROM goiardi.policy_revisions WHERE FALSE;

ROLLBACK;
