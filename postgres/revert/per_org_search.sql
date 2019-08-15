-- Revert goiardi_postgres:per_org_search from pg

BEGIN;

-- drop any created schemas
DO
$$
DECLARE
	sch_count bigint;
BEGIN
	SELECT count(*) c INTO sch_count FROM information_schema.schemata WHERE schema_name like 'goiardi_search_org_%';
	IF sch_count > 0 THEN
		EXECUTE format('DROP SCHEMA %s CASCADE', (SELECT string_agg(schema_name, ', ') FROM information_schema.schemata WHERE schema_name like 'goiardi_search_org_%'));
	END IF;
END;
$$;

DROP FUNCTION goiardi_search_base.delete_search_item(col text, item text, m_organization_id int);
DROP FUNCTION goiardi_search_base.delete_search_collection(col text, m_organization_id int);
DROP TABLE goiardi_search_base.search_items;
DROP TABLE goiardi_search_base.search_collections;
DROP SCHEMA goiardi_search_base;

-- Restore the old search functions and tables

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
	item_name text,
	value text,
	path goiardi.ltree,
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
CREATE INDEX search_org_col_name ON goiardi.search_items(organization_id, search_collection_id, item_name);
CREATE INDEX search_item_val_trgm ON goiardi.search_items USING gist (value goiardi.gist_trgm_ops);
CREATE INDEX search_multi_gist_idx ON goiardi.search_items USING gist (path, value goiardi.gist_trgm_ops);
CREATE INDEX search_val ON goiardi.search_items(value);

CREATE OR REPLACE FUNCTION goiardi.delete_search_item(col text, item text, m_organization_id int) RETURNS VOID AS
$$
DECLARE
	sc_id bigint;
BEGIN
	SELECT id INTO sc_id FROM goiardi.search_collections WHERE name = col AND organization_id = m_organization_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'The collection % does not exist!', col;
	END IF;
	DELETE FROM goiardi.search_items WHERE organization_id = m_organization_id AND search_collection_id = sc_id AND item_name = item;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION goiardi.delete_search_collection(col text, m_organization_id int) RETURNS VOID AS
$$
DECLARE
	sc_id bigint;
BEGIN
	SELECT id INTO sc_id FROM goiardi.search_collections WHERE name = col AND organization_id = m_organization_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'The collection % does not exist!', col;
	END IF;
	DELETE FROM goiardi.search_items WHERE organization_id = m_organization_id AND search_collection_id = sc_id;
	DELETE FROM goiardi.search_collections WHERE organization_id = m_organization_id AND id = sc_id;
END;
$$
LANGUAGE plpgsql;

COMMIT;
