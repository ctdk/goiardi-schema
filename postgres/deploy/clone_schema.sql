-- Deploy goiardi_postgres:clone_schema to pg

-- This function's built from the examples at
-- https://wiki.postgresql.org/wiki/Clone_schema and
-- https://www.postgresql.org/message-id/CANu8FiyJtt-0q%3DbkUxyra66tHi6FFzgU8TqVR2aahseCBDDntA%40mail.gmail.com

BEGIN;

CREATE OR REPLACE FUNCTION goiardi.clone_schema(source_schema text, dest_schema text) RETURNS void AS
$$
 
DECLARE
	object text;
	buffer text;
	default_ text;
	column_ text;
	f_oid oid;
	s_oid oid;
	src_func text;
	dest_func text;
BEGIN
	EXECUTE 'CREATE SCHEMA ' || quote_ident(dest_schema) ;
 
	FOR object IN
		SELECT sequence_name::text FROM information_schema.SEQUENCES WHERE sequence_schema = quote_ident(source_schema)
	LOOP
		EXECUTE 'CREATE SEQUENCE ' || quote_ident(dest_schema) || '.' || object;
	END LOOP;
 
	FOR object IN
		SELECT TABLE_NAME::text FROM information_schema.TABLES WHERE table_schema = quote_ident(source_schema)
	LOOP
		buffer := dest_schema || '.' || object;
		EXECUTE 'CREATE TABLE ' || buffer || ' (LIKE ' || quote_ident(source_schema) || '.' || quote_ident(object) || ' INCLUDING CONSTRAINTS INCLUDING INDEXES INCLUDING DEFAULTS)';
 
		FOR column_, default_ IN
			SELECT column_name::text, REPLACE(column_default::text, source_schema, dest_schema) FROM information_schema.COLUMNS WHERE table_schema = dest_schema AND TABLE_NAME = object AND column_default LIKE 'nextval(%' || source_schema || '%::regclass)'
		LOOP
			EXECUTE 'ALTER TABLE ' || buffer || ' ALTER COLUMN ' || column_ || ' SET DEFAULT ' || default_;
		END LOOP;
	END LOOP;

	SELECT oid INTO s_oid
		FROM pg_namespace
	WHERE nspname = quote_ident(source_schema);

	FOR f_oid IN
		SELECT oid
			FROM pg_proc
			WHERE pronamespace = s_oid

	LOOP
		SELECT pg_get_functiondef(f_oid) INTO src_func;
		SELECT replace(src_func, source_schema, dest_schema) INTO dest_func;
		EXECUTE dest_func;

	END LOOP;

	RETURN;

END;
 
$$ LANGUAGE plpgsql VOLATILE;

COMMIT;
