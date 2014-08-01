-- Verify shovey

BEGIN;

SELECT id, run_id, command, status, timeout, quorum, created_at, updated_at FROM goiardi.shoveys WHERE false;
SELECT id, shovey_run_id, shovey_id, node_name, status, ack_time, end_time, output, err_msg, exit_status FROM goiardi.shovey_runs WHERE false;

ROLLBACK;
