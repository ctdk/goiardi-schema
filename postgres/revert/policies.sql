-- Revert goiardi_postgres:policyfiles from pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.policy_updated_time();

DROP TABLE IF EXISTS goiardi.policies;

COMMIT;
