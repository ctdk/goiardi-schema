-- Deploy shovey

BEGIN;

CREATE TABLE goiardi.shoveys (
	id bigserial,
	run_id uuid not null,
	command text,
	status text,
	timeout int default 300,
	quorum varchar(25) default '100%',
	created_at timestamp with time zone not null,
	updated_at timestamp with time zone not null,
	primary key(id),
	unique(run_id)
);

CREATE TABLE goiardi.shovey_runs (
	id bigserial,
	shovey_run_id uuid not null,
	shovey_id bigint not null,
	node_name text,
	status text,
	ack_time timestamp with time zone not null,
	end_time timestamp with time zone not null,
	primary key(id)
);

CREATE INDEX shoveys_status ON goiardi.shoveys(status);
CREATE INDEX shovey_run_run_id ON goiardi.shovey_runs(shovey_run_id);
CREATE INDEX shovey_run_shovey_id ON goiardi.shovey_runs(shovey_id);
CREATE INDEX shovey_run_node_name ON goiardi.shovey_runs(node_name);
CREATE INDEX shovey_run_status ON goiardi.shovey_runs(status);

COMMIT;
