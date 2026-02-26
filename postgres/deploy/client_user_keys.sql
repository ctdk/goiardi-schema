-- Deploy goiardi_postgres:client_user_keys to pg

BEGIN;

-- While these are almost the same, it would be a headache to stuff both client
-- and user keys into the same table.

CREATE TABLE goiardi.client_keys (
	id bigserial,
	client_id bigint not null,
	name text not null,
	public_key text,
	expiration_date timestamp,
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	unique(client_id, name)
);

CREATE TABLE goiardi.user_keys (
	id bigserial,
	user_id bigint not null,
	name text not null,
	public_key text,
	expiration_date timestamp,
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	unique(client_id, name)
);

COMMIT;
