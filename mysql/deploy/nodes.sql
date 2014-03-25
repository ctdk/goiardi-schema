-- Deploy nodes

BEGIN;

CREATE TABLE nodes (
	id int unsigned not null auto_increment,
	name varchar(255) not null,
	environment_id int unsigned not null default 1,
	run_list blob,
	automatic_attr blob,
	normal_attr blob,
	default_attr blob,
	override_attr blob,
	created_at datetime not null,
	updated_at datetime not null,
	primary key(id),
	unique key(name),
	key(environment_id) -- remove foreign key here; set default on delete
			    -- with a trigger for MySQL; pg does the right thing
			    -- apparently.
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPRESSED;

COMMIT;
