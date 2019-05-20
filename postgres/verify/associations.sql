-- Verify goiardi_postgres:associations on pg

BEGIN;

SELECT id, user_id, organization_id, association_request_id, created_at, updated_at FROM goiardi.associations WHERE FALSE;
SELECT id, user_id, organization_id, status, created_at, updated_at FROM goiardi.association_requests WHERE FALSE;

ROLLBACK;
