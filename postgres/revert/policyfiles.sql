-- Revert goiardi_postgres:policyfiles from pg

BEGIN;

DROP TABLE IF EXISTS goiardi.policies;

COMMIT;
