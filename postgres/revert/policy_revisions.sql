-- Revert goiardi_postgres:policy_revisions from pg

BEGIN;

DROP TABLE IF EXISTS goiardi.policy_revisions;

COMMIT;
