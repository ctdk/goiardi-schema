-- Revert goiardi_postgres:clone_schema from pg

BEGIN;

DROP FUNCTION clone_schema(source_schema text, dest_schema text);

COMMIT;
