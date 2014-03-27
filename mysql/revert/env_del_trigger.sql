-- Revert env_del_trigger

BEGIN;

DROP TRIGGER clear_node_env;

COMMIT;
