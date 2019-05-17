-- Deploy goiardi_postgres:drop_search_schema to pg

BEGIN;

CREATE OR REPLACE FUNCTION drop_search_schema(search_schema text) RETURNS void AS
$$

BEGIN
	EXECUTE 'DROP SCHEMA ' || quote_ident(search_schema) || ' CASCADE';
END;

$$
LANGUAGE plpgsql VOLATILE;

COMMIT;
