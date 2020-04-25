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

-- Only for the policy_revision trigger
CREATE OR REPLACE FUNCTION goiardi.policy_updated_time() RETURNS TRIGGER AS
$$
DECLARE p_id bigint;
BEGIN
IF NEW IS NULL THEN
	RAISE NOTICE 'NEW was null\n';
	p_id := OLD.policy_id;
ELSE
	RAISE NOTICE E'NEW was not null\n';
	p_id := NEW.policy_id;
END IF;
RAISE NOTICE E'p_id is %\n', p_id;

UPDATE goiardi.policies SET updated_at = NOW() WHERE id = p_id;
RETURN NULL;

END;
$$
LANGUAGE plpgsql;

COMMIT;
