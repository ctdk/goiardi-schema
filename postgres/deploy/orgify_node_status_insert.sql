-- Deploy goiardi_postgres:orgify_node_status_insert to pg

BEGIN;

DROP FUNCTION IF EXISTS goiardi.insert_node_status(m_name text, m_status goiardi.status_node);

CREATE OR REPLACE FUNCTION goiardi.insert_node_status(m_name text, m_status goiardi.status_node, m_organization_id bigint) RETURNS VOID AS
$$
DECLARE
	n BIGINT;
BEGIN
	SELECT id INTO n FROM goiardi.nodes WHERE name = m_name and organization_id = m_organization_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'aiiie, the node % was deleted while we were doing something else trying to insert a status', m_name;
	END IF;
	INSERT INTO goiardi.node_statuses (node_id, status, updated_at) VALUES (n, m_status, NOW());
	RETURN;
END;
$$
LANGUAGE plpgsql;

COMMIT;
