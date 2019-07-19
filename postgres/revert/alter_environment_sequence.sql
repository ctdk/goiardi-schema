-- Revert goiardi_postgres:alter_environment_sequence from pg

BEGIN;

-- There's not really a good way, nor a good reason, to undo this particular
-- change, so do nothing.

COMMIT;
