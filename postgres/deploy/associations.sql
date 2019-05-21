-- Deploy goiardi_postgres:associations to pg

BEGIN;

CREATE TYPE goiardi.association_req_status AS ENUM ('pending', 'accepted', 'rejected');

CREATE TABLE goiardi.associations(
	id bigserial,
	user_id bigint,
	organization_id bigint,
	association_request_id bigint,
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	unique(user_id, organization_id)
);

CREATE INDEX assoc_req_assoc ON goiardi.associations(association_request_id);

CREATE TABLE goiardi.association_requests(
	id bigserial,
	user_id bigint,
	organization_id bigint,
	inviter_id bigint,
	status goiardi.association_req_status default 'pending',
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	unique(user_id, organization_id, inviter_id)
);

CREATE INDEX assoc_req_status_idx ON goiardi. association_requests(status);

COMMIT;
