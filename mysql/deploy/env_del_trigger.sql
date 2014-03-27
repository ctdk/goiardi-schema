-- Deploy env_del_trigger

BEGIN;

DELIMITER //
CREATE DEFINER=`root`@`localhost` TRIGGER clear_node_env AFTER DELETE ON environments FOR EACH ROW
BEGIN
SELECT id FROM environments WHERE name = '_default' INTO @a;
update nodes set environment_id = @a where environment_id = OLD.id;
END;//

DELIMITER ;

COMMIT;
