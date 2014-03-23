-- Deploy cookbook_versions

BEGIN;

CREATE TABLE cookbook_versions (
	id int unsigned not null auto_increment,
	cookbook_id int unsigned not null,
	major_ver bigint unsigned not null,
	minor_ver bigint unsigned not null,
	patch_ver bigint unsigned not null,
	frozen tinyint default 0,
	metadata blob,
	definitions blob,
	libraries blob,
	attributes blob,
	recipes blob,
	providers blob,
	resources blob,
	templates blob,
	root_files blob,
	files blob,
	created_at datetime default null,
	updated_at datetime default null,
	PRIMARY KEY(id),
	UNIQUE KEY(cookbook_id, major_ver, minor_ver, patch_ver),
	FOREIGN KEY (cookbook_id)
		REFERENCES cookbooks(id)
		ON DELETE RESTRICT,
	INDEX(frozen)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPRESSED;

COMMIT;
