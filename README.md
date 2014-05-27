goiardi-schema
==============

This is a [sqitch][] project for managing the [goiardi][] schemas. Using sqitch 
for managing the schemas for goiardi was inspired by seeing 
[chef-server-schema][], but while the goiardi schemas obviously have a lot in 
common with the official erchef schemas, they aren't the same.

The MySQL schema is used in goiardi as of version 0.5.0. The
[sqitch MySQL tutorial][] explains how to set up and use sqitch, and the
[MySQL mode README section][] in goiardi explains how to use sqitch to deploy the
goiardi schema and configure goiardi to use MySQL.

[goiardi]:https://github.com/ctdk/goiardi
[sqitch]:http://sqitch.org
[chef-server-schema]:https://github.com/opscode/chef-server-schema
[sqitch MySQL tutorial]:https://metacpan.org/pod/sqitchtutorial-mysql
[MySQL mode README section]:https://github.com/ctdk/goiardi#mysql-mode
