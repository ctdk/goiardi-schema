goiardi-schema
==============

This is a [sqitch][] project for managing the [goairdi][] schemas as they're 
developed.  Using sqitch for managing the schemas for goiardi was inspired by 
seeing [chef-server-schema][], but while the goiardi schemas obviously have a 
lot in common with the official erchef schemas, they aren't the same.

At the moment the MySQL goiardi schema is under development. A Postgres schema 
is planned, but won't even be started until after the MySQL schema's done.

Once both the schema and goiardi are ready, this README will be a lot more
interesting, but until then it's a bit sparse sadly.

[goiardi]:https://github.com/ctdk/goiardi
[sqitch]:http://sqitch.org
[chef-server-schema]:https://github.com/opscode/chef-server-schema
