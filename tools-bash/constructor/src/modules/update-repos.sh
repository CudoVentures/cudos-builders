#!/bin/bash -i

echo -ne "Updating the repos...";

branch="cudos-dev"

cd "$PARAM_SOURCE_DIR/CudosNode"
git pull origin $branch &> /dev/null
if [ "$?" != 0 ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error updating the cudos-node repo. Please try in a while";
    exit 1;
fi
git fetch --tags --force &> /dev/null
if [ "$?" != 0 ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error updating the cudos-node repo. Please try in a while";
    exit 1;
fi

cd "$PARAM_SOURCE_DIR/CudosBuilders"
git pull origin $branch &> /dev/null
if [ "$?" != 0 ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error updating the cudos-builders repo. Please try in a while";
    exit 1;
fi
git fetch --tags --force &> /dev/null
if [ "$?" != 0 ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error updating the cudos-builders repo. Please try in a while";
    exit 1;
fi

cd "$PARAM_SOURCE_DIR/CudosGravityBridge"
git pull origin $branch &> /dev/null
if [ "$?" != 0 ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error updating the cudos-gravity-bridge repo. Please try in a while";
    exit 1;
fi
git fetch --tags --force &> /dev/null
if [ "$?" != 0 ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error updating the cudos-gravity-bridge repo. Please try in a while";
    exit 1;
fi

genesisPath="$PARAM_SOURCE_DIR/CudosBuilders/docker/config/genesis.mainnet.json"
if [ ! -f "$genesisPath" ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} The $genesisPath file is missing";
    exit 1;
fi

if [ ! -r "$WORKING_DIR/config/genesis.mainnet.json" ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} Permission denied $genesisPath";
    exit 1;
fi

jq "." "$genesisPath" &> /dev/null
if [ "$?" != 0 ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} The $genesisPath is invalid";
    exit 1;
fi

echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";
