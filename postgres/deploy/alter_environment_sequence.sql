-- Deploy goiardi_postgres:alter_environment_sequence to pg

BEGIN;

ALTER SEQUENCE goiardi.environments_id_seq START WITH 2 RESTART;

COMMIT;
