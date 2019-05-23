-- Deploy goiardi_postgres:associations to pg

BEGIN;

CREATE TYPE goiardi.association_req_status AS ENUM ('pending', 'accepted', 'rejected', 'removed');
CREATE TYPE goiardi.association_req_inviter AS ENUM ('users', 'clients');

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
	inviter_type goiardi.association_req_inviter,
	status goiardi.association_req_status default 'pending',
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	-- I'm starting to wonder a little bit if this index is too ridonk for
	-- words.
	unique(user_id, organization_id, inviter_id, inviter_type)
);

CREATE INDEX assoc_req_status_idx ON goiardi.association_requests(status);

-- turns out we should have a merge function for association_requests.

CREATE OR REPLACE FUNCTION goiardi.merge_association_requests(m_user_id bigint, m_org_id bigint, m_inviter_id bigint, m_inviter_type text, m_status text)
	RETURNS VOID AS
$$
BEGIN
	LOOP
		-- Try updating the association req first
		UPDATE goiardi.association_requests assoc SET status = m_status, updated_at = NOW() WHERE user_id = m_user_id AND organization_id = m_org_id AND inviter_id = m_inviter_id AND inviter_type = m_inviter_type;
		IF found THEN
			RETURN;
		END IF;
		-- not found, so insert
		BEGIN
			INSERT INTO goiardi.association_requests (user_id, organization_id, inviter_id, inviter_type, status, created_at, updated_at) VALUES (m_user_id, m_org_id, m_inviter_id, m_inviter_type, m_status, NOW(), NOW());
		EXCEPTION WHEN unique_violation THEN
		END;
	END LOOP;
END:
$$
LANGUAGE plpgsql;

COMMIT;
