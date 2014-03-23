-- Deploy users

BEGIN;

CREATE TABLE users (
	id int unsigned not null auto_increment,
	username varchar(255),
	name varchar(1024),
	email varchar(255),
	admin tinyint(4) default 0,
	passwd varchar(128),
	salt varbinary(64),
	created_at datetime default null,
	updated_at datetime default null,
	primary key(id),
	unique key(username),
	unique key(email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

COMMIT;
