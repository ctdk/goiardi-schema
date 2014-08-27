-- Deploy shovey_insert_update
-- requires: shovey

BEGIN;

CREATE OR REPLACE FUNCTION goiardi.merge_shoveys(m_run_id uuid, m_command text, m_status text, m_timeout int, m_quorum varchar(25)) RETURNS VOID AS
$$
BEGIN
    LOOP
	UPDATE goiardi.shoveys SET status = m_status, updated_at = NOW() WHERE run_id = m_run_id;
        IF found THEN
	    RETURN;
    	END IF;
    	BEGIN
	    INSERT INTO goiardi.shoveys (run_id, command, status, timeout, quorum, created_at, updated_at) VALUES (m_run_id, m_command, m_status, m_timeout, m_quorum, NOW(), NOW());
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            -- moo.
    	END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION goiardi.merge_shovey_runs(m_shovey_run_id uuid, m_node_name text, m_status text, m_ack_time timestamp with time zone, m_end_time timestamp with time zone, m_output text, m_error text, m_stderr text, m_exit_status integer) RETURNS VOID AS
$$
DECLARE
    m_shovey_id bigint;
BEGIN
    LOOP
	UPDATE goiardi.shovey_runs SET status = m_status, ack_time = m_ack_time, end_time = m_end_time, output = m_output, stderr = m_stderr, exit_status = cast(m_exit_status as smallint) WHERE shovey_run_id = m_shovey_run_id AND node_name = m_node_name;
	IF found THEN
	    RETURN;
	END IF;
	BEGIN
	    SELECT id INTO m_shovey_id FROM goiardi.shoveys WHERE run_id = m_shovey_run_id;
	    INSERT INTO goiardi.shovey_runs (shovey_run_id, shovey_id, node_name, status, ack_time, end_time, output, error, stderr, exit_status) VALUES (m_shovey_run_id, m_shovey_id, m_node_name, m_status, m_ack_time, m_end_time, m_output, m_error, m_stderr, cast(m_exit_status as smallint));
	EXCEPTION WHEN unique_violation THEN
	    -- meh.
	END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

COMMIT;
