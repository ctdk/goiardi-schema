-- Revert goiardi_postgres:goiardi_10_schemas from pg

BEGIN;

DROP SCHEMA goiardi_search_base;

COMMIT;
