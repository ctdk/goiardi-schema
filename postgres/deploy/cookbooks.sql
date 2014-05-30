-- Deploy cookbooks
-- requires: goiardi_schema

BEGIN;

CREATE TABLE goiardi.cookbooks (
	id bigserial,
	name text not null,
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	unique(name)
);

COMMIT;
