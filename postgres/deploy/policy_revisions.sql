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
	UNIQUE(policy_id, revision_id),
	FOREIGN KEY(policy_id)
		REFERENCES goiardi.policies(id)
		ON DELETE CASCADE
);

ALTER TABLE goiardi.policy_revisions ALTER run_list SET STORAGE EXTERNAL;

ALTER TABLE goiardi.policy_revisions ALTER cookbook_locks SET STORAGE EXTERNAL;

ALTER TABLE goiardi.policy_revisions ALTER default_attr SET STORAGE EXTERNAL;

ALTER TABLE goiardi.policy_revisions ALTER override_attr SET STORAGE EXTERNAL;

ALTER TABLE goiardi.policy_revisions ALTER solution_dependencies SET STORAGE EXTERNAL;

CREATE INDEX revision_policy_id ON goiardi.policy_revisions(policy_id);

CREATE TRIGGER goiardi_rev_policy_updated_time
	AFTER INSERT OR UPDATE OR DELETE ON goiardi.policy_revisions
	FOR EACH ROW
	EXECUTE FUNCTION goiardi.policy_updated_time();

COMMIT;
