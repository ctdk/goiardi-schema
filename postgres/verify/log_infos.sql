-- Verify log_infos

BEGIN;

SELECT id, actor_id, actor_info, actor_type, organization_id, time, action, object_type, object_name, extended_info FROM goiardi.log_infos WHERE FALSE;

ROLLBACK;
