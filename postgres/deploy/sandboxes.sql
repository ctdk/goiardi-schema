-- Deploy sandboxes
-- requires: goiardi_schema

BEGIN;

CREATE TABLE goiardi.sandboxes (
	id bigserial,
	sbox_id varchar(32) not null,
	creation_time timestamp with time zone not null,
	checksums bytea,
	completed boolean,
	primary key(id),
	unique(sbox_id)
);

ALTER TABLE goiardi.sandboxes ALTER checksums SET STORAGE EXTERNAL;

COMMIT;
