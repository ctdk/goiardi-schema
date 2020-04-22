-- Verify goiardi_postgres:policyfiles on pg

BEGIN;

SELECT id, name, organization_id, created_at, updated_at FROM goiardi.policies WHERE FALSE;

ROLLBACK;
