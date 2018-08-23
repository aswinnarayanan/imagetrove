#!/bin/bash

apt-get -y install postgresql-10

cd /etc/postgresql/10/main/
cp postgresql.conf postgresql.conf.BAK && chattr +i postgresql.conf.BAK
sed -i -e 's/#listen_addresses/listen_addresses/g' postgresql.conf

cp pg_hba.conf pg_hba.conf.BAK && chattr +i pg_hba.conf.BAK
cat >pg_hba.conf <<EOL
local all postgres trust
local all all trust
host all all 127.0.0.1 255.255.255.255 trust
host all all ::1/128 md5
EOL

service postgresql restart

createuser --username=postgres --no-superuser --pwprompt admin
createdb --username=postgres --owner=admin --encoding=UNICODE tardis_db

pi install psycopg2
pip install south
pip install django-longerusernameandemail

