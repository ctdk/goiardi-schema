-- Revert goiardi_postgres:associations from pg

BEGIN;

DROP TABLE goiardi.associations;
DROP TABLE goiardi.association_requests;
DROP TYPE goiardi.association_req_inviter;
DROP TYPE goiardi.association_req_status;

COMMIT;
