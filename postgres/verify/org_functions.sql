-- Verify goiardi_postgres:org_functions on pg

BEGIN;

SELECT goiardi.merge_orgs('foopler', 'nermsnerm');
SELECT id FROM goiardi.organizations WHERE name = 'foopler' AND description = 'nermsnerm';

SELECT goiardi.merge_orgs('foopler', 'blarghmy');
SELECT id FROM goiardi.organizations WHERE name = 'foopler' AND description = 'blarghmy';

ROLLBACK;
