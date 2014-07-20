-- Revert bytea_to_bytea

BEGIN;

ALTER TABLE goiardi.cookbook_versions
	ALTER COLUMN metadata TYPE bytea USING NULL,
	ALTER COLUMN definitions TYPE bytea USING NULL,
	ALTER COLUMN libraries TYPE bytea USING NULL,
	ALTER COLUMN attributes TYPE bytea USING NULL,
	ALTER COLUMN recipes TYPE bytea USING NULL,
	ALTER COLUMN resources TYPE bytea USING NULL,
	ALTER COLUMN providers TYPE bytea USING NULL,
	ALTER COLUMN templates TYPE bytea USING NULL,
	ALTER COLUMN root_files TYPE bytea USING NULL,
	ALTER COLUMN files TYPE bytea USING NULL;

ALTER TABLE goiardi.data_bag_items
	ALTER COLUMN raw_data TYPE bytea USING NULL;

ALTER TABLE goiardi.environments
	ALTER COLUMN default_attr TYPE bytea USING NULL,
	ALTER COLUMN override_attr TYPE bytea USING NULL,
	ALTER COLUMN cookbook_vers TYPE bytea USING NULL;

ALTER TABLE goiardi.nodes
	ALTER COLUMN run_list TYPE bytea USING NULL,
	ALTER COLUMN automatic_attr TYPE bytea USING NULL,
	ALTER COLUMN normal_attr TYPE bytea USING NULL,
	ALTER COLUMN default_attr TYPE bytea USING NULL,
	ALTER COLUMN override_attr TYPE bytea USING NULL;

ALTER TABLE goiardi.reports
	ALTER COLUMN resources TYPE bytea USING NULL,
	ALTER COLUMN data TYPE bytea USING NULL;

ALTER TABLE goiardi.roles
	ALTER COLUMN run_list TYPE bytea USING NULL,
	ALTER COLUMN env_run_lists TYPE bytea USING NULL,
	ALTER COLUMN default_attr TYPE bytea USING NULL,
	ALTER COLUMN override_attr TYPE bytea USING NULL;

ALTER TABLE goiardi.sandboxes
	ALTER COLUMN checksums TYPE bytea USING NULL;

DROP FUNCTION goiardi.merge_cookbook_versions(c_id bigint, is_frozen bool, defb json, libb json, attb json, recb json, prob json, resb json, temb json, roob json, filb json, metb json, maj bigint, min bigint, patch bigint);

DROP FUNCTION goiardi.insert_dbi(m_data_bag_name text, m_name text, m_orig_name text, m_dbag_id bigint, m_raw_data json);

DROP FUNCTION goiardi.merge_environments(m_name text, m_description text, m_default_attr json, m_override_attr json, m_cookbook_vers json);

DROP FUNCTION goiardi.merge_nodes(m_name text, m_chef_environment text, m_run_list json, m_automatic_attr json, m_normal_attr json, m_default_attr json, m_override_attr json);

DROP FUNCTION goiardi.merge_reports(m_run_id uuid, m_node_name text, m_start_time timestamp with time zone, m_end_time timestamp with time zone, m_total_res_count int, m_status goiardi.report_status, m_run_list text, m_resources json, m_data json);

DROP FUNCTION goiardi.merge_roles(m_name text, m_description text, m_run_list json, m_env_run_lists json, m_default_attr json, m_override_attr json);

DROP FUNCTION goiardi.merge_sandboxes(m_sbox_id varchar(32), m_creation_time timestamp with time zone, m_checksums json, m_completed boolean);

CREATE OR REPLACE FUNCTION goiardi.merge_cookbook_versions(c_id bigint, is_frozen bool, defb bytea, libb bytea, attb bytea, recb bytea, prob bytea, resb bytea, temb bytea, roob bytea, filb bytea, metb bytea, maj bigint, min bigint, patch bigint) RETURNS BIGINT AS
$$
DECLARE
    cbv_id BIGINT;
BEGIN
    LOOP
        -- first try to update the key
        UPDATE goiardi.cookbook_versions SET frozen = is_frozen, metadata = metb, definitions = defb, libraries = libb, attributes = attb, recipes = recb, providers = prob, resources = resb, templates = temb, root_files = roob, files = filb, updated_at = NOW() WHERE cookbook_id = c_id AND major_ver = maj AND minor_ver = min AND patch_ver = patch RETURNING id INTO cbv_id;
        IF found THEN
            RETURN cbv_id;
        END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
            INSERT INTO goiardi.cookbook_versions (cookbook_id, major_ver, minor_ver, patch_ver, frozen, metadata, definitions, libraries, attributes, recipes, providers, resources, templates, root_files, files, created_at, updated_at) VALUES (c_id, maj, min, patch, is_frozen, metb, defb, libb, attb, recb, prob, resb, temb, roob, filb, NOW(), NOW()) RETURNING id INTO cbv_id;
            RETURN c_id;
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION goiardi.insert_dbi(m_data_bag_name text, m_name text, m_orig_name text, m_dbag_id bigint, m_raw_data bytea) RETURNS BIGINT AS
$$
DECLARE
	u BIGINT;
	dbi_id BIGINT;
BEGIN
	SELECT id INTO u FROM goiardi.data_bags WHERE id = m_dbag_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'aiiiie! The data bag % was deleted from the db while we were doing something else', m_data_bag_name;
	END IF;

	INSERT INTO goiardi.data_bag_items (name, orig_name, data_bag_id, raw_data, created_at, updated_at) VALUES (m_name, m_orig_name, m_dbag_id, m_raw_data, NOW(), NOW()) RETURNING id INTO dbi_id;
	RETURN dbi_id;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION goiardi.merge_environments(m_name text, m_description text, m_default_attr bytea, m_override_attr bytea, m_cookbook_vers bytea) RETURNS VOID AS
$$
BEGIN
    LOOP
        -- first try to update the key
	UPDATE goiardi.environments SET description = m_description, default_attr = m_default_attr, override_attr = m_override_attr, cookbook_vers = m_cookbook_vers, updated_at = NOW() WHERE name = m_name;
	IF found THEN
		RETURN;
	END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
	    INSERT INTO goiardi.environments (name, description, default_attr, override_attr, cookbook_vers, created_at, updated_at) VALUES (m_name, m_description, m_default_attr, m_override_attr, m_cookbook_vers, NOW(), NOW());
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION goiardi.merge_nodes(m_name text, m_chef_environment text, m_run_list bytea, m_automatic_attr bytea, m_normal_attr bytea, m_default_attr bytea, m_override_attr bytea) RETURNS VOID AS
$$
BEGIN
    LOOP
        -- first try to update the key
	UPDATE goiardi.nodes SET chef_environment = m_chef_environment, run_list = m_run_list, automatic_attr = m_automatic_attr, normal_attr = m_normal_attr, default_attr = m_default_attr, override_attr = m_override_attr, updated_at = NOW() WHERE name = m_name;
	IF found THEN
	    RETURN;
	END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
	    INSERT INTO goiardi.nodes (name, chef_environment, run_list, automatic_attr, normal_attr, default_attr, override_attr, created_at, updated_at) VALUES (m_name, m_chef_environment, m_run_list, m_automatic_attr, m_normal_attr, m_default_attr, m_override_attr, NOW(), NOW());
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION goiardi.merge_reports(m_run_id uuid, m_node_name text, m_start_time timestamp with time zone, m_end_time timestamp with time zone, m_total_res_count int, m_status goiardi.report_status, m_run_list text, m_resources bytea, m_data bytea) RETURNS VOID AS
$$
BEGIN
    LOOP
        -- first try to update the key
	UPDATE goiardi.reports SET start_time = m_start_time, end_time = m_end_time, total_res_count = m_total_res_count, status = m_status, run_list = m_run_list, resources = m_resources, data = m_data, updated_at = NOW() WHERE run_id = m_run_id;
	IF found THEN
	    RETURN;
	END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
	    INSERT INTO goiardi.reports (run_id, node_name, start_time, end_time, total_res_count, status, run_list, resources, data, created_at, updated_at) VALUES (m_run_id, m_node_name, m_start_time, m_end_time, m_total_res_count, m_status, m_run_list, m_resources, m_data, NOW(), NOW());
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION goiardi.merge_roles(m_name text, m_description text, m_run_list bytea, m_env_run_lists bytea, m_default_attr bytea, m_override_attr bytea) RETURNS VOID AS
$$
BEGIN
    LOOP
        -- first try to update the key
	UPDATE goiardi.roles SET description = m_description, run_list = m_run_list, env_run_lists = m_env_run_lists, default_attr = m_default_attr, override_attr = m_override_attr, updated_at = NOW() WHERE name = m_name;
	IF found THEN
	    RETURN;
	END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
	    INSERT INTO goiardi.roles (name, description, run_list, env_run_lists, default_attr, override_attr, created_at, updated_at) VALUES (m_name, m_description, m_run_list, m_env_run_lists, m_default_attr, m_override_attr, NOW(), NOW());
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION goiardi.merge_sandboxes(m_sbox_id varchar(32), m_creation_time timestamp with time zone, m_checksums bytea, m_completed boolean) RETURNS VOID AS
$$
BEGIN
    LOOP
        -- first try to update the key
	UPDATE goiardi.sandboxes SET checksums = m_checksums, completed = m_completed WHERE sbox_id = m_sbox_id;
	IF found THEN
	    RETURN;
	END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
	    INSERT INTO goiardi.sandboxes (sbox_id, creation_time, checksums, completed) VALUES (m_sbox_id, m_creation_time, m_checksums, m_completed);
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            -- Do nothing, and loop to try the UPDATE again.
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

COMMIT;

COMMIT;
