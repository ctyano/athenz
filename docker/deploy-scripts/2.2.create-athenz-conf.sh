#!/bin/sh

# to script directory
cd "$(dirname "$0")"

# to project root
cd ../..

# variables
USER_TOKEN_PATH=${USER_TOKEN_PATH:-"`pwd`/docker/deploy-scripts/user-token.txt"}
[[ -r "${USER_TOKEN_PATH}" ]] && N_TOKEN_PATH="${USER_TOKEN_PATH}"
N_TOKEN_PATH=${N_TOKEN_PATH:-"`pwd`/docker/deploy-scripts/n-token.txt"}
DOCKER_NETWORK=${DOCKER_NETWORK:-athenz}
ZMS_HOST=${ZMS_HOST:-athenz-zms-server}
ZTS_HOST=${ZTS_HOST:-athenz-zts-server}

# get ZMS container info.
ZMS_CONTAINER=`docker ps -aqf "name=zms-server"`

# confirm zms version
printf "\n"
docker run --rm --name athenz-zms-cli athenz-zms-cli version

# confirm the user token is valid
printf "\nWill create athenz.conf...\n"
docker run --rm -it --network="${DOCKER_NETWORK}" \
  -v "${N_TOKEN_PATH}:/etc/token/ntoken" \
  -v "`pwd`/docker/zms/var/certs/zms_cert.pem:/etc/certs/zms_cert.pem" \
  -v "`pwd`/docker/zts/conf/athenz.conf:/tmp/athenz.conf" \
  --name athenz-cli-util athenz-cli-util \
  ./utils/athenz-conf/target/linux/athenz-conf \
  -f /etc/token/ntoken \
  -z "https://${ZMS_HOST}:4443" -c /etc/certs/zms_cert.pem \
  -t "https://${ZTS_HOST}:8443" \
  -o /tmp/athenz.conf
