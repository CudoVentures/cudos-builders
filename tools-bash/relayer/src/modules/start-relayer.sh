#!/bin/bash -i

echo -ne "Cleaning the docker...";
dockerResult=$(docker system prune -a -f 2>&1)
dockerResult=$(docker container prune -f 2>&1)
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

echo -ne "Preparing the binary builder...";
cd "$PARAM_SOURCE_DIR/CudosBuilders/docker/hermes-ibc-relayer"
dockerResult=$(sudo docker-compose -f ./hermes-ibc-relayer-binary-builder.yml -p hermes-ibc-relayer-binary-builder --env-file ./hermes-ibc-relayer.mainnet.arg build 2>&1)
if [ "$?" != 0 ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error building the container $?: ${dockerResult}";
    exit 1;
fi
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

echo -ne "Stopping previous INIT instances...";
docker-compose -f ./hermes-ibc-relayer-init.yml -p hermes-ibc-relayer-init --env-file ./hermes-ibc-relayer.mainnet.arg down &> /dev/null
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

echo -ne "Initialize...";
dockerResult=$(docker-compose -f ./hermes-ibc-relayer-init.yml -p hermes-ibc-relayer-init --env-file ./hermes-ibc-relayer.mainnet.arg up --build -d 2>&1)
if [ "$?" != 0 ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error building the container $?: ${dockerResult}";
    exit 1;
fi

dockerResult=$(docker wait hermes-ibc-relayer-init 2>&1)
if [ "$?" != 0 ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error building the container $?: ${dockerResult}";
    exit 1;
fi

if [ "$1" = "start" ]; then
    initResultError=$(cat $PARAM_SOURCE_DIR/CudosData/cudos-data-hermes-ibc-relayer/create-channel-data.txt | grep error)
    if [ "$initResultError" != "" ]; then
        echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error while in the init script: ${initResultError}";
        exit 1;
    fi
    initResult=$(cat $PARAM_SOURCE_DIR/CudosData/cudos-data-hermes-ibc-relayer/create-channel-data.txt)
    initResultSearchFor="Success:"
    CONNECTION_INFO=${initResult#*$initResultSearchFor}
fi
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

echo -ne "Stopping previous START instances...";
docker-compose -f ./hermes-ibc-relayer-start.yml -p hermes-ibc-relayer-start --env-file ./hermes-ibc-relayer.mainnet.arg down &> /dev/null
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

echo -ne "Starting...";
dockerResult=$(docker-compose -f ./hermes-ibc-relayer-start.yml -p hermes-ibc-relayer-start --env-file ./hermes-ibc-relayer.mainnet.arg up --build -d 2>&1)
if [ "$?" != 0 ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error building the container $?: ${dockerResult}";
    exit 1;
fi
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

