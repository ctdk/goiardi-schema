-- Deploy goiardi_postgres:per_org_search to pg

BEGIN;

-- Remove the old search tables. Yes, this means that on the off chance you're
-- upgrading that you'll need to rebuild the search db, but that's not such a
-- bad idea in this situation.

DROP FUNCTION goiardi.delete_search_item(col text, item text, m_organization_id int);
DROP FUNCTION goiardi.delete_search_collection(col text, m_organization_id int);
DROP TABLE goiardi.search_items;
DROP TABLE goiardi.search_collections;

-- Create a new base search schema. Each organization will get their very own
-- separate search schema, rather than stuffing everything into the same one.
-- The hope is that by doing so, everyone's searches will be faster and, just
-- maybe, the indices will be smaller on disk as well.

-- The ltree and pg_trgm extensions have already been loaded, so we don't need
-- to do that again.

CREATE SCHEMA goiardi_search_base;

CREATE TABLE goiardi_search_base.search_collections (
	id bigserial,
	organization_id bigint not null default 1,
	name text,
	PRIMARY KEY(id),
	UNIQUE(organization_id, name)
);

CREATE TABLE goiardi_search_base.search_items (
	id bigserial,
	organization_id bigint not null default 1,
	search_collection_id bigint not null,
	item_name text,
	value text,
	path goiardi.ltree,
	PRIMARY KEY(id),
	FOREIGN KEY (search_collection_id)
		REFERENCES goiardi_search_base.search_collections(id)
		ON DELETE RESTRICT
);


CREATE INDEX search_col_name ON goiardi_search_base.search_collections(name);
CREATE INDEX search_org_id ON goiardi_search_base.search_items(organization_id);
CREATE INDEX search_org_col ON goiardi_search_base.search_items(organization_id, search_collection_id);
CREATE INDEX search_gist_idx ON goiardi_search_base.search_items USING gist (path);
CREATE INDEX search_btree_idx ON goiardi_search_base.search_items USING btree(path);
CREATE INDEX search_org_col_name ON goiardi_search_base.search_items(organization_id, search_collection_id, item_name);
CREATE INDEX search_item_val_trgm ON goiardi_search_base.search_items USING gist (value goiardi.gist_trgm_ops);
CREATE INDEX search_multi_gist_idx ON goiardi_search_base.search_items USING gist (path, value goiardi.gist_trgm_ops);
CREATE INDEX search_val ON goiardi_search_base.search_items(value);

-- Do the delete functions in here as well.

CREATE OR REPLACE FUNCTION goiardi_search_base.delete_search_item(col text, item text, m_organization_id int) RETURNS VOID AS
$$
DECLARE
	sc_id bigint;
BEGIN
	SELECT id INTO sc_id FROM goiardi_search_base.search_collections WHERE name = col AND organization_id = m_organization_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'The collection % does not exist!', col;
	END IF;
	DELETE FROM goiardi_search_base.search_items WHERE organization_id = m_organization_id AND search_collection_id = sc_id AND item_name = item;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION goiardi_search_base.delete_search_collection(col text, m_organization_id int) RETURNS VOID AS
$$
DECLARE
	sc_id bigint;
BEGIN
	SELECT id INTO sc_id FROM goiardi_search_base.search_collections WHERE name = col AND organization_id = m_organization_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'The collection % does not exist!', col;
	END IF;
	DELETE FROM goiardi_search_base.search_items WHERE organization_id = m_organization_id AND search_collection_id = sc_id;
	DELETE FROM goiardi_search_base.search_collections WHERE organization_id = m_organization_id AND id = sc_id;
END;
$$
LANGUAGE plpgsql;

COMMIT;
