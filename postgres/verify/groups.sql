-- Verify goiardi_postgres:groups on pg

BEGIN;

-- Not quite ready - actors and groups still need to be added to the table.
SELECT id, name, organization_id, created_at, updated_at FROM goiardi.groups WHERE FALSE;

ROLLBACK;
