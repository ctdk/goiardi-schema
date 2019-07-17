-- Revert goiardi_postgres:drop_search_schema from pg

BEGIN;

DROP PROCEDURE goiardi.drop_search_schema(search_schema text);

COMMIT;
