-- Revert goiardi_postgres:policy_revisions from pg

BEGIN;

DROP TRIGGER IF EXISTS goiardi_rev_policy_updated_time ON goiardi.policy_revisions;
DROP INDEX IF EXISTS goiardi.revision_policy_id;
DROP TABLE IF EXISTS goiardi.policy_revisions;

COMMIT;
