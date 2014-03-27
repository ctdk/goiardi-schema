-- Verify env_del_trigger

BEGIN;

INSERT INTO environments (name) values ("env_test");
SELECT id FROM environments WHERE name = "env_test" INTO @env_id;
SELECT id FROM environments WHERE name = "_default" INTO @default_id;
INSERT INTO nodes (name, environment_id) VALUES ("test_node", @env_id);
DELETE FROM environments WHERE id = @env_id;
SELECT id FROM nodes WHERE name = "test_node" AND environment_id = @default_id;

ROLLBACK;
