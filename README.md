goiardi-schema
==============

This is a [sqitch][] project for managing the [goiardi][] schemas. Using sqitch for managing the schemas for goiardi was inspired by seeing [chef-server-schema][], but while the goiardi schemas obviously have a lot in common with the official erchef schemas, they aren't the same.

The MySQL schema is used in goiardi from version 0.5.0, including all 0.11.x releases, up until 1.0.0. The [sqitch MySQL tutorial][] explains how to set up and use sqitch, and the [MySQL mode README section][] in goiardi explains how to use sqitch to deploy the goiardi schema and configure goiardi to use MySQL.

The Postgres schema is used in goiardi as of version 0.6.0. The [sqitch Postgres tutorial][] explains how to set up and use sqitch for Postgres, and the [Postgres mode README section][] in goiardi explains how to use sqitch to deploy the goiardi schema and configure goiardi to use PostgreSQL.

While most of the tables here are unique to goiardi and not directly derived from the erchef schemas, as noted in the NOTICE file and the appropriate SQL files the joined_cookbook_version view is directly adapted to goiardi from the one found in erchef.

[goiardi]:https://github.com/ctdk/goiardi
[sqitch]:http://sqitch.org
[chef-server-schema]:https://github.com/opscode/chef-server-schema
[sqitch MySQL tutorial]:https://metacpan.org/pod/sqitchtutorial-mysql
[MySQL mode README section]:https://github.com/ctdk/goiardi#mysql-mode
[sqitch Postgres tutorial]:https://metacpan.org/pod/sqitchtutorial
[Postgres mode README section]:https://github.com/ctdk/goiardi#postgres-mode
