-- Verify goiardi_postgres:containers on pg

BEGIN;

SELECT id, name, organization_id, created_at, updated_at FROM goiardi.containers WHERE FALSE;

ROLLBACK;
