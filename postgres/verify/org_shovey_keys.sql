-- Verify goiardi_postgres:org_shovey_keys on pg

BEGIN;

SELECT shovey_key FROM goiardi.organizations;

ROLLBACK;
