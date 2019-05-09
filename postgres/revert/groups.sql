-- Revert goiardi_postgres:groups from pg

BEGIN;

DROP TABLE goiardi.groups;

COMMIT;
