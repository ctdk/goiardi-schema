-- Revert goiardi_postgres:containers from pg

BEGIN;

DROP TABLE goiardi.containers;

COMMIT;
