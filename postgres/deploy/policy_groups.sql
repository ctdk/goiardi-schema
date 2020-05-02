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
	UNIQUE(pg_id, policy_id),
	FOREIGN KEY(policy_rev_id)
		REFERENCES goiardi.policy_revisions(id)
		ON DELETE CASCADE,
	FOREIGN KEY(policy_id)
		REFERENCES goiardi.policies(id)
		ON DELETE CASCADE,
	FOREIGN KEY(pg_id)
		REFERENCES goiardi.policy_groups(id)
		ON DELETE CASCADE
);

CREATE INDEX pg_revision_id ON goiardi.policy_groups_to_policies(policy_id, policy_rev_id);

-- Same caveat with this function as with merge_policies.
CREATE OR REPLACE FUNCTION goiardi.merge_policy_groups(m_name text, m_organization_id bigint) RETURNS VOID AS
$$
BEGIN
	INSERT INTO goiardi.policy_groups(name, organization_id, created_at, updated_at)
		VALUES (m_name, m_organization_id, NOW(), NOW())
		ON CONFLICT(organization_id, name)
		DO UPDATE SET
			updated_at = NOW();
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION goiardi.merge_policy_groups_to_policies(m_pg_id bigint, m_policy_id bigint, m_policy_rev_id bigint) RETURNS VOID AS
$$
BEGIN
	INSERT INTO goiardi.policy_groups_to_policies
		(pg_id, policy_id, policy_rev_id, created_at, updated_at)
		VALUES (m_pg_id, m_policy_id, m_policy_rev_id, NOW(), NOW())
		ON CONFLICT(pg_id, policy_id)
		DO UPDATE SET
			policy_rev_id = m_policy_rev_id,
			updated_at = NOW();
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION goiardi.policy_group_updated_time() RETURNS TRIGGER AS
$$
DECLARE pg_id bigint;
BEGIN
IF NEW IS NULL THEN
	pg_id := OLD.pg_id;
ELSE
	pg_id := NEW.pg_id;
END IF;

UPDATE goiardi.policy_groups SET updated_at = NOW() WHERE id = pg_id;
RETURN NULL;

END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER goiardi_pg_policy_updated_time
	AFTER INSERT OR UPDATE OR DELETE ON goiardi.policy_groups_to_policies
	FOR EACH ROW
	EXECUTE FUNCTION goiardi.policy_updated_time();

CREATE TRIGGER goiardi_pg_policy_group_updated_time
	AFTER INSERT OR UPDATE OR DELETE ON goiardi.policy_groups_to_policies
	FOR EACH ROW
	EXECUTE FUNCTION goiardi.policy_group_updated_time();

COMMIT;
