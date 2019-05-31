-- Verify goiardi_postgres:clone_schema on pg

BEGIN;

SELECT goiardi.clone_schema('goiardi_search_base', 'goiardi_search_vfy');
SELECT pg_catalog.has_schema_privilege('goiardi_search_vfy', 'usage');

ROLLBACK;
