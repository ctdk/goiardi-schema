-- Verify sandboxes

BEGIN;

SELECT id, sbox_id, creation_time, checksums FROM goiardi.sandboxes WHERE FALSE;

ROLLBACK;
