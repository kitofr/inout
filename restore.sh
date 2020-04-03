DOCKER_DB_NAME="$(docker-compose ps -q db)"
DB_HOSTNAME=inout_dev
DB_USER=postgres
LOCAL_DUMP_PATH="latest.dump"

docker-compose up -d db
docker exec -i "${DOCKER_DB_NAME}" createdb "${DB_HOSTNAME}" -U "${DB_USER}"
docker exec -i "${DOCKER_DB_NAME}" pg_restore -C --verbose --clean --no-acl --no-owner -U "${DB_USER}" -d "${DB_HOSTNAME}" < "${LOCAL_DUMP_PATH}"
docker-compose stop db

echo "Remember to rename the created database to inout_dev!"
echo "./connect.sh"
echo "\c postgres"
echo "drop database inout_dev;"
echo "ALTER DATABASE db RENAME TO inout_dev;"

echo """inout_dev-# \c postgres
You are now connected to database "postgres" as user "postgres".
postgres=# drop database inout_dev;
DROP DATABASE
postgres=# ALTER DATABASE d5pugpujpktpup RENAME TO inout_dev;
ALTER DATABASE
postgres=# \c inout_dev ;
You are now connected to database "inout_dev" as user "postgres".
inout_dev=# select * from users;
 id |      email       |                       crypted_password                       |     inserted_at     |     updated_at
----+------------------+--------------------------------------------------------------+---------------------+---------------------
  1 | kitofr@gmail.com | $2b$12$vvjhnpwBSqxaSBrHBCP4surRuD86ndpC3OJrjXBBtRMnhxEZvNDGG | 2016-10-11 18:43:42 | 2016-10-11 18:43:42
(1 row)
"""
