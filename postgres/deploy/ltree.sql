-- Deploy ltree

BEGIN;
CREATE EXTENSION ltree;

CREATE TABLE goiardi.search_collections (
	id bigserial,
	organization_id bigint not null default 1,
	name text,
	PRIMARY KEY(id),
	UNIQUE(organization_id, name)
);

CREATE TABLE goiardi.search_items (
	id bigserial,
	organization_id bigint not null default 1,
	search_collection_id bigint not null,
	value text,
	path ltree,
	PRIMARY KEY(id),
	FOREIGN KEY (search_collection_id)
		REFERENCES goiardi.search_collections(id)
		ON DELETE RESTRICT
);


CREATE INDEX search_col_name ON goiardi.search_collections(name);
CREATE INDEX search_org_id ON goiardi.search_items(organization_id);
CREATE INDEX search_org_col ON goiardi.search_items(organization_id, search_collection_id);
CREATE INDEX search_gist_idx ON goiardi.search_items USING gist (path);
CREATE INDEX search_btree_idx ON goiardi.search_items USING btree(path);

COMMIT;
