-- Deploy goiardi_postgres:delete_orgs to pg

BEGIN;

CREATE OR REPLACE PROCEDURE goiardi.delete_org(m_organization_id BIGINT, m_org_search_schema TEXT) AS
$$
	BEGIN
		DELETE FROM goiardi.association_requests WHERE organization_id = m_organization_id;
		DELETE FROM goiardi.associations WHERE organization_id = m_organization_id;
		DELETE FROM goiardi.environments WHERE organization_id = m_organization_id;
		DELETE FROM goiardi.data_bag_items WHERE data_bag_id IN (SELECT id FROM goiardi.data_bags WHERE organization_id = m_organization_id);
		DELETE FROM goiardi.data_bags WHERE organization_id = m_organization_id;
		DELETE FROM goiardi.cookbook_versions WHERE cookbook_id IN (SELECT id FROM goiardi.cookbooks WHERE organization_id = m_organization_id);
		DELETE FROM goiardi.cookbooks WHERE organization_id = m_organization_id;
		DELETE FROM goiardi.roles WHERE organization_id = m_organization_id;
		DELETE FROM goiardi.log_infos WHERE organization_id = m_organization_id;
		DELETE FROM goiardi.reports WHERE organization_id = m_organization_id;
		DELETE FROM goiardi.nodes WHERE organization_id = m_organization_id;
		DELETE FROM goiardi.shovey_run_streams WHERE shovey_run_id IN (SELECT sr.id FROM goiardi.shovey_runs sr JOIN shoveys s ON sr.shovey_id = s.id WHERE s.organization_id = m_organization_id);
		DELETE FROM goiardi.shovey_runs WHERE shovey_id IN (SELECT id FROM shoveys WHERE organization_id = m_organization_id);
		DELETE FROM goiardi.shoveys WHERE organization_id = m_organization_id;
		DELETE FROM goiardi.sandboxes WHERE organization_id = m_organization_id;
		DELETE FROM goiardi.groups WHERE organization_id = m_organization_id;
		DELETE FROM goiardi.clients WHERE organization_id = m_organization_id;

		-- get any straggler file checksums that might still be lurking
		-- in here
		DELETE FROM goiardi.file_checksums WHERE organization_id = m_organization_id;

		-- Delete the search schema
		-- TODO: make this a stored procedure?
		CALL goiardi.drop_search_schema(m_org_search_schema);

		-- zap the containers last of all
		DELETE FROM goiardi.containers WHERE organization_id = m_organization_id;

		DELETE FROM goiardi.organizations WHERE id = m_organization_id;
	END;
$$
LANGUAGE plpgsql;

COMMIT;
