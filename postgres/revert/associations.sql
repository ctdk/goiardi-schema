-- Revert goiardi_postgres:associations from pg

BEGIN;

DROP FUNCTION goiardi.merge_association_requests(m_user_id bigint, m_org_id bigint, m_inviter_id bigint, m_inviter_type goiardi.association_req_inviter, m_status goiardi.association_req_status);
DROP TABLE goiardi.associations;
DROP TABLE goiardi.association_requests;
DROP TYPE goiardi.association_req_inviter;
DROP TYPE goiardi.association_req_status;

COMMIT;
