-- Verify goiardi_postgres:groups on pg

BEGIN;

SELECT id, name, organization_id, actor_users, actor_clients, groups, created_at, updated_at FROM goiardi.groups WHERE FALSE;

SELECT goiardi.merge_groups('gorn', 1, NULL, NULL, NULL);
SELECT id FROM goiardi.groups WHERE name = 'gorn' AND organization_id = 1 AND actor_users IS NULL;

SELECT goiardi.merge_groups('gorn', 1, '{10}');
SELECT id FROM goiardi.organizations WHERE name = 'gorn' AND organization_id = 1 AND actor_users[0] = 10;

SELECT goiardi.rename_group('gorn', 'kirk', 1);
SELECT id FROM goiardi.group WHERE name = 'kirk' AND organization_id = 1;

ROLLBACK;
