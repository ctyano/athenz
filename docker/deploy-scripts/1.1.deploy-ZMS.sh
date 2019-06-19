#!/bin/sh

# to script directory
cd "$(dirname "$0")"

# to project root
cd ../..

# variables
DOCKER_NETWORK=${DOCKER_NETWORK:-athenz}
ZMS_DB_HOST=${ZMS_DB_HOST:-athenz-zms-db}
ZMS_HOST=${ZMS_HOST:-athenz-zms-server}

# check password
[[ -z "$ZMS_JDBC_PASSWORD" ]] && echo "ZMS_JDBC_PASSWORD not set" && exit 1

# docker network
docker network create ${DOCKER_NETWORK}

# start ZMS DB
printf "\nWill start ZMS DB...\n"
docker run -d --rm -h ${ZMS_DB_HOST} \
  -p 3306:3306 \
  --network="${DOCKER_NETWORK}" \
  -v "`pwd`/docker/db/zms/zms-db.cnf:/etc/mysql/conf.d/zms-db.cnf" \
  -e "MYSQL_ROOT_PASSWORD=${ZMS_JDBC_PASSWORD}" \
  --name athenz-zms-db athenz-zms-db

# wait for ZMS DB ready
ZMS_DB_CONTAINER=`docker ps -aqf "name=zms-db"`
docker run --rm \
  --network="${DOCKER_NETWORK}" \
  -v "`pwd`/docker/db/zms/zms-db.cnf:/etc/my.cnf" \
  -e "MYSQL_PWD=${ZMS_JDBC_PASSWORD}" \
  --name wait-for-mysql wait-for-mysql "${ZMS_DB_HOST}"

# start ZMS
printf "\nWill start ZMS server...\n"
docker run -d --rm -h ${ZMS_HOST} \
  -p 4443:4443 \
  --network="${DOCKER_NETWORK}" \
  -v "`pwd`/docker/zms/var:/opt/athenz/zms/var" \
  -v "`pwd`/docker/zms/conf:/opt/athenz/zms/conf/zms_server" \
  -v "`pwd`/docker/logs/zms:/opt/athenz/zms/logs/zms_server" \
  -e "ZMS_JDBC_PASSWORD=${ZMS_JDBC_PASSWORD}" \
  -e "ZMS_SSL_KEYSTORE_PASS=${ZMS_SSL_KEYSTORE_PASS}" \
  -e "ZMS_SSL_TRUSTSTORE_PASS=${ZMS_SSL_TRUSTSTORE_PASS}" \
  --name athenz-zms-server athenz-zms-server

# TODO: wait for ZMS to be ready
printf "\nWill wait for ZMS to be ready...\n"
sleep 10
