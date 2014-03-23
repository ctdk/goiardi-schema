-- Deploy nodes

BEGIN;

CREATE TABLE nodes (
	id int unsigned not null auto_increment,
	name varchar(255) not null,
	environment_id int unsigned default null,
	automatic_attr blob,
	normal_attr blob,
	default_attr blob,
	override_attr blob,
	created_at datetime default null,
	updated_at datetime default null,
	primary key(id),
	unique key(name),
	foreign key(environment_id)
		references environments(id)
		on delete set null
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPRESSED;

COMMIT;
