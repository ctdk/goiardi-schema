-- Verify users

BEGIN;

SELECT id, username, name, email, admin, public_key, passwd, salt, created_at, updated_at FROM users WHERE 0;

ROLLBACK;
