-- Deploy environments
-- requires: goiardi_schema

BEGIN;

CREATE TABLE goiardi.environments (
	id bigserial,
	name text,
	description text,
	default_attr bytea,
	override_attr bytea,
	cookbook_vers bytea, -- make a blob for now, may bust out to a table
	created_at timestamp not null,
	updated_at timestamp not null,
	PRIMARY KEY(id),
	UNIQUE(name)
);
ALTER TABLE goiardi.environments ALTER default_attr SET STORAGE EXTERNAL;
ALTER TABLE goiardi.environments ALTER override_attr SET STORAGE EXTERNAL;
ALTER TABLE goiardi.environments ALTER cookbook_vers SET STORAGE EXTERNAL;

INSERT INTO goiardi.environments (id, name, description, created_at, updated_at) VALUES (1, '_default', 'The default Chef environment', NOW(), NOW());

COMMIT;
