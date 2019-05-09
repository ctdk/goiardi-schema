-- Deploy goiardi_postgres:groups to pg

BEGIN;

CREATE TABLE goiardi.groups (
	id bigserial,
	name text not null,
	organization_id bigint not null default 1,

	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	unique(organization_id, name)
);

COMMIT;
