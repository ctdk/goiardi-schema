-- Verify cookbooks

BEGIN;

SELECT id, name, created_at, updated_at FROM goiardi.cookbooks WHERE FALSE;

ROLLBACK;
