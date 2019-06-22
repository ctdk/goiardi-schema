-- Revert goiardi_postgres:org_foreign_keys from pg

BEGIN;

ALTER TABLE goiardi.clients DROP CONSTRAINT clients_organization_id_fkey;
ALTER TABLE goiardi.containers DROP CONSTRAINT containers_organization_id_fkey;
ALTER TABLE goiardi.cookbooks DROP CONSTRAINT cookbooks_organization_id_fkey;
ALTER TABLE goiardi.data_bags DROP CONSTRAINT data_bags_organization_id_fkey;
ALTER TABLE goiardi.environments DROP CONSTRAINT environments_organization_id_fkey;
ALTER TABLE goiardi.file_checksums DROP CONSTRAINT file_checksums_organization_id_fkey;
ALTER TABLE goiardi.groups DROP CONSTRAINT groups_organization_id_fkey;
ALTER TABLE goiardi.group_actor_users DROP CONSTRAINT group_actor_users_organization_id_fkey;
ALTER TABLE goiardi.group_actor_clients DROP CONSTRAINT group_actor_clients_organization_id_fkey;
ALTER TABLE goiardi.group_groups DROP CONSTRAINT group_groups_organization_id_fkey;
ALTER TABLE goiardi.log_infos DROP CONSTRAINT log_infos_organization_id_fkey;
ALTER TABLE goiardi.nodes DROP CONSTRAINT nodes_organization_id_fkey;
ALTER TABLE goiardi.reports DROP CONSTRAINT reports_organization_id_fkey;
ALTER TABLE goiardi.roles DROP CONSTRAINT roles_organization_id_fkey;
ALTER TABLE goiardi.sandboxes DROP CONSTRAINT sandboxes_organization_id_fkey;
ALTER TABLE goiardi.shoveys DROP CONSTRAINT shoveys_organization_id_fkey;
ALTER TABLE goiardi_search_base.search_collections DROP CONSTRAINT search_collections_organization_id_fkey;
ALTER TABLE goiardi_search_base.search_items DROP CONSTRAINT search_items_organization_id_fkey;

COMMIT;
