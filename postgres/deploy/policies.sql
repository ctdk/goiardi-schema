-- Deploy goiardi_postgres:policyfiles to pg

BEGIN;

CREATE TABLE goiardi.policies (
	id BIGSERIAL,
	name TEXT NOT NULL,
	organization_id BIGINT NOT NULL DEFAULT 1,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL,
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
	PRIMARY KEY(id),
	UNIQUE(organization_id, name),
	FOREIGN KEY(organization_id)
		REFERENCES goiardi.organizations(id)
		ON DELETE RESTRICT
);

COMMIT;
