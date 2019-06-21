-- Revert goiardi_postgres:cookbook_org_changes from pg

BEGIN;

-- TODO: drop foreign key/index (whichever it ends up being) on organization_id

COMMIT;
