-- Revert ltree

BEGIN;

DROP TABLE goiardi.search_items;
DROP TABLE goiardi.search_collections;
DROP EXTENSION ltree;

COMMIT;
