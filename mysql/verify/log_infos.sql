-- Verify log_infos

BEGIN;

SELECT id, actor_id, actor_info, actor_type, time, action, object_type, object_name, extended_info FROM log_infos WHERE 0;

ROLLBACK;
