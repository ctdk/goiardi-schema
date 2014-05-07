-- Deploy reports

BEGIN;

CREATE TABLE reports (
	id int not null auto_increment,
	run_id varchar(36) not null,
	node_name varchar(255),
	organization_id int not null default 1,
	start_time datetime,
	end_time datetime,
	total_res_count int default 0,
	status enum("success", "failure"),
	run_list blob,
	resources blob,
	data blob,
	primary key(id),
	unique index(run_id),
	index(organization_id),
	index(node_name, organization_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPRESSED;

COMMIT;
