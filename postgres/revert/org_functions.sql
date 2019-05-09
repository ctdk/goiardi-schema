-- Revert goiardi_postgres:org_functions from pg

BEGIN;

DROP FUNCTION goiardi.merge_orgs(m_name text, m_description text);

COMMIT;
