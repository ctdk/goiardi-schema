-- Revert node_status_insert

BEGIN;

DROP FUNCTION goiardi.insert_node_status(m_name text, m_status varchar(50);

COMMIT;
