-- Deploy data_bag_items

BEGIN;

CREATE TABLE data_bag_items (
	id int unsigned not null auto_increment,
	name varchar(255) not null,
	data_bag_id int unsigned,
	raw_data blob,
	created_at datetime default null,
	updated_at datetime default null,
	primary key(id),
	FOREIGN KEY(data_bag_id)
		REFERENCES data_bags(id)
		ON DELETE RESTRICT,
	unique key(data_bag_id, name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPRESSED;

COMMIT;
