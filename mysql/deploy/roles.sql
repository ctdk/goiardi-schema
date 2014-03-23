-- Deploy roles

BEGIN;

CREATE TABLE roles (
	id int unsigned not null auto_increment,
	name varchar(255) not null,
	description text,
	run_list blob,
	env_run_lists blob,
	default_attr blob,
	override_attr blob,
	created_at datetime default null,
	updated_at datetime default null,
	primary key(id),
	unique key(name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPRESSED;

COMMIT;
