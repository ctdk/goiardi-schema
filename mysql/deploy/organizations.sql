-- Deploy organizations

BEGIN;

CREATE TABLE organizations (
	id int unsigned not null auto_increment,
	name varchar(255),
	description text,
	primary key(id),
	unique key(name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO organizations (name) values ("default");

COMMIT;
