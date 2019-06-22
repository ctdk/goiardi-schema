-- Deploy goiardi_postgres:org_foreign_keys to pg

BEGIN;

ALTER TABLE goiardi.clients ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.containers ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.cookbooks ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.data_bags ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.environments ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.file_checksums ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.groups ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.group_actor_users ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.group_actor_clients ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.group_groups ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.log_infos ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.nodes ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.reports ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.roles ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.sandboxes ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi.shoveys ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi_search_base.search_collections ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

ALTER TABLE goiardi_search_base.search_items ADD FOREIGN KEY (organization_id)
	REFERENCES goiardi.organizations(id)
	ON DELETE RESTRICT;

COMMIT;
