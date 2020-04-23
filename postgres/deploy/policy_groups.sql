-- Deploy goiardi_postgres:policy_groups to pg

BEGIN;

CREATE TABLE goiardi.policy_groups (
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

CREATE TABLE goiardi.policy_groups_to_policies (
	id BIGSERIAL,
	pg_id BIGINT NOT NULL,
	policy_id BIGINT NOT NULL,
	policy_rev_id BIGINT NOT NULL,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL,
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
	PRIMARY KEY(id),
	UNIQUE KEY(policy_id, pg_id, id),
	FOREIGN KEY(policy_rev_id)
		REFERENCES goiardi.policy_revisions(id)
		ON DELETE CASCADE,
	FOREIGN KEY(policy_id)
		REFERENCES goiardi.policies(id)
		ON DELETE CASCADE,
	FOREIGN KEY(pg_id)
		REFERENCES goiardi.policy_groups(id)
		ON DELETE CASCADE
)

COMMIT;
