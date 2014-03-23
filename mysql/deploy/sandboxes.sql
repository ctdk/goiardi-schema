-- Deploy sandboxes

BEGIN;

CREATE TABLE sandboxes (
	id int unsigned not null auto_increment,
	sbox_id varchar(32) not null,
	creation_time datetime default null,
	checksums blob,
	primary key(id),
	unique key(sbox_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

COMMIT;
