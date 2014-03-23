-- Deploy clients

BEGIN;

CREATE TABLE clients (
	id int unsigned not null auto_increment,
	name varchar(2048) not null,
	nodename varchar(2048),
	validator tinyint(4) default 0,
	admin tinyint(4) default 0,
	org_id int not null default 0,
	public_key text,
	certificate text,
	created_at datetime default null,
	updated_at datetime default null,
	primary key(id),
	unique key(org_id, name(250))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

COMMIT;
