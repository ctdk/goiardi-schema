-- Revert shovey

BEGIN;

DROP TABLE goiardi.shoveys;
DROP TABLE goiardi.shovey_runs;

COMMIT;
