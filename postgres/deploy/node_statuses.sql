-- Deploy node_statuses
-- requires: nodes

BEGIN;

CREATE TABLE goiardi.node_statuses (
	id bigserial,
	node_id bigint not null,
	status varchar(50) not null,
	updated_at timestamp with time zone not null,
	PRIMARY KEY(id),
	FOREIGN KEY(node_id)
		REFERENCES goiardi.nodes(id)
		ON DELETE CASCADE
);
CREATE INDEX node_status_status ON goiardi.node_statuses(status);

COMMIT;
