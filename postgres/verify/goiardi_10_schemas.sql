-- Verify goiardi_postgres:goiardi_10_schemas on pg

BEGIN;

SELECT pg_catalog.has_schema_privilege('goiardi_search_base', 'usage');

ROLLBACK;
