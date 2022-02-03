#!/bin/bash -i

validatorIp=$(getComputerIp $validatorComputerIndex)

seedsSize=$(getSeedsSize)
SEEDS_PEERS=()
for i in $(seq 0 $(($seedsSize-1)))
do
    seedComputerId=$(getSeedComputerId $i)
    seedComputerIndex=$(getComputerIndexById "$seedComputerId")

    seedComputerIp=$(getComputerIp $seedComputerIndex)
    seedComputerPort=$(getComputerPort $seedComputerIndex)
    seedComputerUser=$(getComputerUser $seedComputerIndex)

    echo -ne "Preparing seed($i)'s repos...";
    branch="cudos-dev"
    ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR && rm -rf ./CudosNode && git clone -q --branch $branch https://github.com/CudoVentures/cudos-node.git CudosNode"
    ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR && rm -rf ./CudosBuilders && git clone -q --branch $branch https://github.com/CudoVentures/cudos-builders.git CudosBuilders"
    ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR && rm -rf ./CudosGravityBridge && git clone -q --branch $branch https://github.com/CudoVentures/cosmos-gravity-bridge.git CudosGravityBridge"
    echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

    arg=$(ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR/CudosBuilders/docker/seed-node && cat ./seed-node.mainnet.arg")
    startContainerName=$(readEnvFromString "$arg" "START_CONTAINER_NAME")
    unset arg
    result=$(ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR/CudosBuilders/docker/seed-node && sudo docker stop $startContainerName 2> /dev/null")
    ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR && sudo rm -rf ./CudosData"

    echo -ne "Preparing seed($i)'s binary builder...";
    result=$(ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR/CudosBuilders/docker/binary-builder && sudo docker-compose --env-file ./binary-builder.arg -f ./binary-builder.yml -p cudos-binary-builder build 2> /dev/null");
    if [ "$?" != 0 ]; then
        echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error $?: ${result}";
        exit 1;
    fi
    echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

    seedNodeEnv=$(cat $(getSeedEnvPath $i))
    ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR/CudosBuilders/docker/seed-node && echo \"$seedNodeEnv\" > ./seed-node.mainnet.env"
    ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR/CudosBuilders/docker/config && echo \"${GENESIS_JSON//\"/\\\"}\" > ./genesis.mainnet.json"

    echo -ne "Preparing seed($i)'s peers...";
    ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR/CudosBuilders/docker/seed-node && sed -i \"s/PERSISTENT_PEERS=/PERSISTENT_PEERS=\\\"$VALIDATOR_TENEDRMINT_NODE_ID@$validatorIp:26656\\\"/g\" ./seed-node.mainnet.env"
    ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR/CudosBuilders/docker/seed-node && sed -i \"s/PRIVATE_PEERS=/PRIVATE_PEERS=\\\"$VALIDATOR_TENEDRMINT_NODE_ID\\\"/g\" ./seed-node.mainnet.env"
    echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

    echo -ne "Initialize seed($i)...";
    result=$(ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR/CudosBuilders/docker/seed-node && sudo docker-compose --env-file ./seed-node.mainnet.arg -f ./init-seed-node.yml -p cudos-init-seed-node up --build 2> /dev/null")
    if [ "$?" != 0 ]; then
        echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error $?: ${result}";
        exit 1;
    fi
    echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

    echo -ne "Clean-up after the initialization of the seed($i)...";
    result=$(ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR/CudosBuilders/docker/seed-node && sudo docker-compose --env-file ./seed-node.mainnet.arg -f ./init-seed-node.yml -p cudos-init-seed-node down 2> /dev/null")
    if [ "$?" != 0 ]; then
        echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error $?: ${result}";
        exit 1;
    fi
    echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

    echo -ne "Starting seed($i)...";
    result=$(ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "cd $PARAM_SOURCE_DIR/CudosBuilders/docker/seed-node && sudo docker-compose --env-file ./seed-node.mainnet.arg -f ./start-seed-node.yml -p cudos-start-seed-node up --build -d 2> /dev/null")
    if [ "$?" != 0 ]; then
        echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There was an error $?: ${result}";
        exit 1;
    fi
    echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

    tendermintNodeId=$(ssh -o "StrictHostKeyChecking no" ${seedComputerUser}@${seedComputerIp} -p ${seedComputerPort} "sudo docker container exec $startContainerName cudos-noded tendermint show-node-id")
    SEEDS_PEERS+=("$tendermintNodeId@$seedComputerIp:26656")
done

echo -ne "Starting the seeds...";
echo -e "${STYLE_GREEN}DONE${STYLE_DEFAULT}";