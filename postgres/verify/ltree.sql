-- Verify ltree

BEGIN;

SELECT id, organization_id, name FROM goiardi.search_collections WHERE false;
SELECT id, organization_id, search_collection_id, value, path FROM goiardi.search_items WHERE false;
ROLLBACK;
