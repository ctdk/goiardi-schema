-- Deploy log_infos

BEGIN;

DROP TABLE log_infos;
CREATE TABLE log_infos (
	id int not null auto_increment,
	actor_id int not null default 0,
	actor_info text,
	actor_type enum ( 'user', 'client') NOT NULL,
	time timestamp default current_timestamp,
	action enum('create', 'delete', 'modify') not null,
	object_type varchar(100) not null,
	object_name varchar(255) not null,
	extended_info text,
	primary key(id),
	index(actor_id),
	index(action),
	index(object_type, object_name),
	index(time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPRESSED;

COMMIT;
