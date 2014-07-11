-- Revert node_statuses

BEGIN;

DROP TABLE goiardi.node_statuses;

COMMIT;
