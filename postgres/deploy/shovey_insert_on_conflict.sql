-- Deploy goiardi_postgres:shovey_insert_on_conflict to pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.merge_shoveys(m_run_id uuid, m_command text, m_status text, m_timeout bigint, m_quorum varchar(25));

CREATE OR REPLACE FUNCTION goiardi.merge_shoveys(m_run_id uuid, m_command text, m_status text, m_timeout bigint, m_quorum varchar(25), m_organization_id bigint) RETURNS VOID AS
$$
BEGIN
    INSERT INTO goiardi.shoveys (run_id, command, status, timeout, quorum, created_at, updated_at)
        VALUES (m_run_id, m_command, m_status, m_timeout, m_quorum, NOW(), NOW())
        ON CONFLICT(run_id)
            DO UPDATE SET
                status = m_status, 
                updated_at = NOW();
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION goiardi.merge_shovey_runs(m_shovey_run_id uuid, m_node_name text, m_status text, m_ack_time timestamp with time zone, m_end_time timestamp with time zone, m_error text, m_exit_status integer) RETURNS VOID AS
$$
DECLARE
    m_shovey_id bigint;
BEGIN
    -- I'm not sure why, but I think this INSERT statement may have just called
    -- me "Miss Jackson".
    SELECT id INTO m_shovey_id FROM goiardi.shoveys WHERE run_id = m_shovey_run_id;
    INSERT INTO goiardi.shovey_runs (
        shovey_uuid,
        shovey_id,
        node_name,
        status,
        ack_time,
        end_time,
        error,
        exit_status
        ) 
        VALUES (
            m_shovey_run_id,
            m_shovey_id,
            m_node_name,
            m_status,
            NULLIF(m_ack_time,
                '0001-01-01 00:00:00 +0000'),
            NULLIF(m_end_time,
                '0001-01-01 00:00:00 +0000'),
            m_error,
            cast(m_exit_status as smallint)
            )
        ON CONFLICT(shovey_id, node_name)
            DO UPDATE SET 
                status = m_status,
                ack_time = NULLIF(m_ack_time,
                    '0001-01-01 00:00:00 +0000'),
                end_time = NULLIF(m_end_time,
                    '0001-01-01 00:00:00 +0000'),
                error = m_error,
                exit_status = cast(m_exit_status as smallint);
END;
$$
LANGUAGE plpgsql;

COMMIT;
