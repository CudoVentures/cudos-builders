export USER_NAME="user-01"
export USER_ID="1234"
export GROUP_NAME="user-01"
export GROUP_ID="1234"
export DOCKER_GROUP_ID=$(getent group docker | awk -F: '{printf "%d", $3}')
export WORKDIR="/usr/nodes"
export SSH_PORT="30022"
export CONTAINER_NAME="cudos-launcher-node-01"
docker-compose -f ./node.yml -p cudos-launcher-node-01 up --build -d

mkdir -p ./ssh
if [ $USER_NAME = "root" ]; then
    docker cp ${CONTAINER_NAME}:/root/.ssh/keys/access-key "./ssh/$CONTAINER_NAME"
fi
if [ $USER_NAME != "root" ]; then
    docker cp ${CONTAINER_NAME}:/home/${USER_NAME}/.ssh/keys/access-key "./ssh/$CONTAINER_NAME"
fi