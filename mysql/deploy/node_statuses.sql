-- Deploy node_statuses
-- requires: nodes

BEGIN;

CREATE TABLE node_statuses (
	id int not null auto_increment,
	node_id int not null,
	status varchar(50) not null,
	updated_at datetime not null,
	PRIMARY KEY(id),
	INDEX(status),
	FOREIGN KEY(node_id)
		REFERENCES nodes(id)
		ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

COMMIT;
