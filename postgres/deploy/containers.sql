-- Deploy goiardi_postgres:containers to pg

BEGIN;

CREATE TABLE goiardi.containers(
	id bigserial,
	name text,
	organization_id bigint NOT NULL DEFAULT 1,
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	unique(name, organization_id)
);

-- This particular index isn't unique.
CREATE INDEX container_org_id ON goiardi.containers(organization_id);

COMMIT;
