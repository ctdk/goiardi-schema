-- Deploy goiardi_postgres:reports_insert_on_conflict to pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.merge_reports(m_run_id uuid, m_node_name text, m_start_time timestamp with time zone, m_end_time timestamp with time zone, m_total_res_count int, m_status goiardi.report_status, m_run_list text, m_resources jsonb, m_data jsonb);

CREATE OR REPLACE FUNCTION goiardi.merge_reports(m_run_id uuid, m_node_name text, m_start_time timestamp with time zone, m_end_time timestamp with time zone, m_total_res_count int, m_status goiardi.report_status, m_run_list text, m_resources jsonb, m_data jsonb, m_organization_id bigint) RETURNS VOID AS
$$
BEGIN
    INSERT INTO goiardi.reports (run_id, node_name, start_time, end_time, total_res_count, status, run_list, resources, data, created_at, updated_at, organization_id) 
        VALUES (m_run_id, m_node_name, m_start_time, m_end_time, m_total_res_count, m_status, m_run_list, m_resources, m_data, NOW(), NOW(), m_organization_id)
        ON CONFLICT(run_id)
        DO UPDATE SET
            start_time = m_start_time,
            end_time = m_end_time,
            total_res_count = m_total_res_count,
            status = m_status,
            run_list = m_run_list,
            resources = m_resources,
            data = m_data,
            updated_at = NOW();
END;
$$
LANGUAGE plpgsql;

COMMIT;
