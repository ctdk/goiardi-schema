-- Deploy goiardi_postgres:policy_revisions to pg

BEGIN;

CREATE TABLE goiardi.policy_revisions (
	id BIGSERIAL,
	policy_id BIGINT NOT NULL,
	revision_id VARCHAR(64),
	run_list jsonb,
	cookbook_locks jsonb,
	default_attr jsonb,
	override_attr jsonb,
	solution_dependencies jsonb,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL,
	PRIMARY KEY(id),
	UNIQUE(policy_id, revision_id), -- This *may* need to be unique to a policy, but
			     -- probably not
	FOREIGN KEY(policy_id)
		REFERENCES goiardi.policies(id)
		ON DELETE CASCADE
);

COMMIT;
