DOCKER_DB_NAME="$(docker-compose ps -q db)"
DB_HOSTNAME=inout_dev
DB_USER=postgres
LOCAL_DUMP_PATH="latest.dump"

docker-compose up -d db
docker exec -it "${DOCKER_DB_NAME}" psql -U "${DB_USER}" -d "${DB_HOSTNAME}"
docker-compose stop db
