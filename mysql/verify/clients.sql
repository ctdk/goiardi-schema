-- Verify clients

BEGIN;

SELECT id, name, nodename, validator, admin, org_id, public_key, certificate, created_at, updated_at FROM clients;

ROLLBACK;
