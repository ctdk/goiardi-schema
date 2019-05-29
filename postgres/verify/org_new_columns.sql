-- Verify goiardi_postgres:org_new_columns on pg

BEGIN;

SELECT id, name, full_name, description, guid, uuid, created_at, updated_at FROM goiardi.organizations WHERE FALSE;

ROLLBACK;
