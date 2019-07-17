-- Revert goiardi_postgres:delete_orgs from pg

BEGIN;

DROP PROCEDURE goiardi.delete_org(m_organization_id BIGINT, m_org_search_schema TEXT);

COMMIT;
