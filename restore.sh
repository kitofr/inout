DOCKER_DB_NAME="$(docker-compose ps -q db)"
DB_HOSTNAME=inout_dev
DB_USER=postgres
LOCAL_DUMP_PATH="latest.dump"

docker-compose up -d db
docker exec -i "${DOCKER_DB_NAME}" pg_restore -C --verbose --clean --no-acl --no-owner -U "${DB_USER}" -d "${DB_HOSTNAME}" < "${LOCAL_DUMP_PATH}"
docker-compose stop db

echo "Remember to rename the created database to inout_dev!"
echo "ALTER DATABASE db RENAME TO newdb"
