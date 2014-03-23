-- Deploy cookbooks

BEGIN;

CREATE TABLE cookbooks (
	id int unsigned not null auto_increment,
	name varchar(255) not null,
	created_at datetime default null,
	updated_at datetime default null,
	primary key(id),
	unique key(name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

COMMIT;
