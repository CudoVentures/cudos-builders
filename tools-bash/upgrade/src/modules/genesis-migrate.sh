#!/bin/bash -i

echo "" # new line

echo -e "${STYLE_BOLD}Migrating the genesis.json:${STYLE_DEFAULT}";

echo -ne "Configuring the node in sleep mode...";
cd "$NODE_BUILDERS_DOCKER_PATH"
sed -i "s/cudos-noded start/sleep infinity/g" "./$START_DOCKERFILE";
sed -i "s/--state-sync.snapshot-interval 2000 --state-sync.snapshot-keep-recent 2//g" "./$START_DOCKERFILE";
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

echo -ne "Starting the container for migration...";
cd "$NODE_BUILDERS_DOCKER_PATH"
dockerResult=$(docker-compose --env-file $NODE_ARG_PATH -f ./$START_YML -p ${START_CONTAINER_NAME} up --build -d 2>&1);
if [ "$?" != 0 ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error building the sleeping node for migration $?: ${dockerResult}";
    exit 1;
fi
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

if [ "$USE_PREDEFINED_GENESIS" = "false" ]; then
    echo -ne "Migrating genesis.json...";
    \cp -f "$WORKING_MIGRATE_DIR/genesis.exported.json" "$WORKING_MIGRATE_DIR/genesis.migrated.json"

    if [ "$UPDATE_FROM_VERSION" = "v0.3" ] && [ "$UPDATE_TO_VERSION" = "v0.6.0" ]; then
        # no need to execute cudos-noded migrate because both version are running cosmos-sdk-0.44
        source "$WORKING_SRC_VERSIONS_DIR/genesis-0.3-0.6.sh"
    elif [ "$UPDATE_FROM_VERSION" = "v0.5.0" ] && [ "$UPDATE_TO_VERSION" = "v0.6.0" ]; then
        # no need to execute cudos-noded migrate because both version are running cosmos-sdk-0.44
        source "$WORKING_SRC_VERSIONS_DIR/genesis-0.5-0.6.sh"
    elif [ "$UPDATE_FROM_VERSION" = "v0.4.0" ] && [ "$UPDATE_TO_VERSION" = "v0.9.0" ]; then
        # no need to execute cudos-noded migrate because there is not need for it from v0.44 to v0.45
        source "$WORKING_SRC_VERSIONS_DIR/genesis-0.4-0.9.sh"
    elif [ "$UPDATE_FROM_VERSION" = "v0.6.0" ] && [ "$UPDATE_TO_VERSION" = "v0.8.0" ]; then
        # no need to execute cudos-noded migrate because there is not need for it from v0.44 to v0.45
        source "$WORKING_SRC_VERSIONS_DIR/genesis-0.6-0.8.sh"
    elif [ "$UPDATE_FROM_VERSION" = "v0.8.0" ] && [ "$UPDATE_TO_VERSION" = "v1.1.0" ]; then
        source "$WORKING_SRC_VERSIONS_DIR/genesis-0.8-1.1.sh"
    fi

    \cp -f "$WORKING_MIGRATE_DIR/genesis.migrated.json" "$VOLUME_PATH/config/genesis.json"
else
    echo -ne "Copying genesis.json...";
    \cp -f "$BUILDERS_GENESIS_PATH" "$VOLUME_PATH/config/genesis.json"
fi

user=$(ls -ld "$WORKING_MIGRATE_DIR/.." | awk '{print $3}')
group=$(ls -ld "$WORKING_MIGRATE_DIR/.." | awk '{print $4}')

chown "$user":"$group" -R "$WORKING_MIGRATE_DIR"
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

echo -ne "Resetting the state...";
docker container exec $START_CONTAINER_NAME /bin/bash -c "cudos-noded unsafe-reset-all" &> /dev/null
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

echo -ne "Stopping the container...";
docker stop "$START_CONTAINER_NAME" &> /dev/null
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

echo -ne "Restoring the node in default mode...";
cd "$NODE_BUILDERS_DOCKER_PATH"
if [ "$PARAM_NODE_NAME" = "root-node" ] || [ "$PARAM_NODE_NAME" = "full-node" ]; then
    sed -i "s/sleep infinity/cudos-noded start/g" "./$START_DOCKERFILE";
else
    sed -i "s/sleep infinity/cudos-noded start --state-sync.snapshot-interval 2000 --state-sync.snapshot-keep-recent 2/g" "./$START_DOCKERFILE";
fi
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";
