-- Revert goiardi_postgres:policyfiles from pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.policy_updated_time();
DROP FUNCTION IF EXISTS goiardi.merge_policies(m_name text, m_organization_id bigint);

DROP TABLE IF EXISTS goiardi.policies;

COMMIT;
