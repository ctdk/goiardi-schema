-- Verify goiardi_postgres:per_org_search on pg

BEGIN;

SELECT pg_catalog.has_schema_privilege('goiardi_search_base', 'usage');

ROLLBACK;
