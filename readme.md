# Overview

This project contains a set of building scripts for CudosNetwork. It depends on 5 other projects and should be downloaded manually. Here is the list:
1. CudosNode (https://github.com/CudoVentures/cudos-node)
2. CudosGravityBridge (https://github.com/CudoVentures/cosmos-gravity-bridge)
3. CudosGravityBridgeUI (https://github.com/CudoVentures/cudos-gravity-bridge-ui)
4. CudosExplorer (https://github.com/CudoVentures/big-dipper)
5. CudosFaucet (https://github.com/CudoVentures/faucet)

The following directory structure is required in order everything to work correctly otherwise the scripts will not be able to find their dependancies.
Let denote the parent directory of all projects <code>parentDir</code>. Its name could be arbitrary.

    /parentDir
    - /parentDir/CudosBuilders
    - /parentDir/CudosNode
    - /parentDir/CudosGravityBridge
    - /parentDir/CudosGravityBridgeUI
    - /parentDir/CudosExplorer
    - /parentDir/CudosFaucet
    - /parentDir/CudosData

In the above directory structure, the folders' names are REQUIRED. Carefully rename everyone project to match the folder names above. Create an empty folder CudosData in <code>parentDir</code>

All commands in this guide assume that you are using Linux with bash. If you are using Windows then you are required to install WSL2 which is again Linux with bash.

# System requirements

These system requirements are recommended for usual setup. Spanning a network with a lot of nodes will require more RAM.

<em>**Hardware:**</em>

**CPU:** At least 2 cores.

**RAM:** 16 GB (Windows), 8 GB (Linux)

**Disk:** An SSD drive

<em>**Software:**</em>

**OS:** Linux or Windows with WSL2 enabled.

**Docker:** 20.10.6+

**Docker compose:** 1.29+

<em>Ubuntu 21 is tested and is working well.</em>

<em>Windows 10 with Ubuntu 20.04 on WSL2 is tested and it is working well.</em>

<em>The versions of docker and docker-compose are just an example. It is quite likely to work with older versions too.</em>

# Host and nested dockers permissions

In most docker instances in this project host file system is mounted inside the docker. This could cauce a permission errors unless it is correctly handled. That's why there are configuration files where you MUST specify your host account details in order identical accounts to be created inside docker container.

# CudosBuilders structure

<em>.vscode</em> - Contains predefined set of commands for VSCode only. They can be triggered by Control(or Cmd)+Shift+B.

<em>docker</em> - Contains configuration, docker, docker-compose files for all build variants of the cudos network.

<em>tools</em> - Conains scripts for network deployment.

<em>workspace</em> - Contains VS Code specific files for building a devcontainer including an example of .dockerignore file

More information about each of these folders will follow.

# Setup the workspace (workspace folder)

## VS Code

1. Install "Remote development" extension.
2. Copy everything from <code>/parentDir/CudosBuilders/workspace</code> to <code>parentDir</code>
3. Rename/copy <code>parentDir/.devcontainer/.env.example</code> to <code>parentDir/.devcontainer/.env</code>. There are 7 parameters that you must specify:


        3.1. MNT_PATH - This is the exact path there <code>parentDir</code> is located in the host. Open it in shell and run <code>pwd</code>. The result of the command is the value of MNT_PATH.
        3.2. PASS - This is the password which will be used inside dev container for both root and your accounts.
        3.3. USER_ID - Id of your host's account
        3.4. USER_NAME - Name of your host's account
        3.5. GROUP_ID - Id of your host's account's group
        3.6. GROUP_NAME - Name of your host's account's group
        3.7. DOCKER_GROUP_ID - Id of docker's group from the host
       
4. Open cudos.code-workspace located in <code>parentDir</code>
5. Open View -> Command pallete and type "Reopen in container".

Now your VS Code should reopen and start building the devcontainer. It could take some time. Once it is ready you will see in bottom-left corner the following label "Dev Container: cudos-workspace". In this devcontainer you have already installed Go, Rust, Docker, Docker compose, NodeJs.

## Non-VS Code

1. Copy .dockerignore from <code>/parentDir/CudosBuilders/workspace</code> to <code>parentDir</code> 
2. Install correspoding framework/langage that you are going to use (depends on project). You might need Go, Rust or NodeJs.

# Setup tools (tools folder)

## Configuration for deployment

<em>You can skip this step if you are going to use network deployer or deployer-tls.</em>

Most of the deployers below has a file named <code>secrecs.json.example</code> Duplicate this file and rename it to <code>secrets.json</code> In it you will find predefined instances' names. Let's call them **targets**. Do not change them, just add the corresponding parameters in the empty variables. Each target needs a host, port, username, privateKey, keyPass (if available) and serverPath. If you are deploying to currently running testnets, lease the serverPath as it is - <code>/usr/cudos</code>

## Ethereum deployer

### Usage:
1. Configure <code>secrets.json</code> in this deployer as described above.
2. Use some of the npm commands.

### List of npm commands regarding this deployer:

**<code>deploy--ethereum-rinkeby</code>** - deploys the rinkeby ethereum full node to gcloud using <code>secrets.json</code> in the deployer's folder.

## Gravity bridge ui deployer

### Usage:
1. Configure <code>secrets.json</code> in this deployer as described above.
2. Configure the ENV variables in <code>parentDir/CudosBuilders/docker/gravity-bridge-ui</code>
- Copy <em>gravity-bridge-ui.env.example</em> to:
    - <em>gravity-bridge-ui.testnet.private.env</em> (for private testnet builds)
    - <em>gravity-bridge-ui.testnet.public.env</em> (for public testnet builds)
- Fill the required fields as described in the "ENV files fields" section.

### List of npm commands regarding this deployer:

**<code>deploy-gravity-bridge-ui-testnet-public</code>** - deploys gravity-bridge-ui to public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy-gravity-bridge-ui-testnet-private</code>** - deploys gravity-bridge-ui to private testnet using <code>secrets.json</code> in the deployer's folder.

## network deployer

To do

## nodes deployer

This deployer is responsible of the deployments of root, seed, sentry and full nodes.

### Usage:
1. Configure <code>secrets.json</code> in this deployer as described above.
2. Configure the ENV variables in <code>parentDir/CudosBuilders/docker/root-node</code> (if you are going to build a root-node)
- Copy <em>root-node.env.example</em> to:
    - <em>root-node.testnet.private.env</em> (for root-validator of the private testnet builds)
    - <em>root-node.testnet.public.zone01.env</em> (for root-validator of the public testnet builds)
- Fill the required fields as described in the "ENV files fields" section.
3. Configure the ENV variables in <code>parentDir/CudosBuilders/docker/seed-node</code> (if you are going to build a seed-node)
- Copy <em>seed-node.env.example</em> to:
    - <em>seed-node.testnet.private.env</em> (for 1st seed node of the private testnet builds)
    - <em>seed-node.testnet.public.zone01.env</em> (for 1st seed node of the public testnet builds)
    - <em>seed-node.testnet.public.zone02.env</em> (for 2nd seed node of the public testnet builds)
    - <em>seed-node.testnet.public.zone03.env</em> (for 3th seed node of the public testnet builds)
- Fill the required fields as described in the "ENV files fields" section.
4. Configure the ENV variables in <code>parentDir/CudosBuilders/docker/sentry-node</code> (if you are going to build a sentry-node)
- Copy <em>sentry-node.env.example</em> to:
    - <em>sentry-node.testnet.private.env</em> (for 1st sentry node of the private testnet builds)
    - <em>sentry-node.testnet.public.zone01.env</em> (for 1st sentry node of the public testnet builds)
    - <em>sentry-node.testnet.public.zone02.env</em> (for 2nd sentry node of the public testnet builds)
    - <em>sentry-node.testnet.public.zone03.env</em> (for 3th sentry node of the public testnet builds)
- Fill the required fields as described in the "ENV files fields" section.
5. Configure the ENV variables in <code>parentDir/CudosBuilders/docker/full-node</code> (if you are going to build a validator different from the root one)
- Copy <em>full-node.env.example</em> to:
    - <em>full-node.testnet.public.zone02.env</em> (for 2nd full node of the public testnet builds)
    - <em>full-node.testnet.public.zone03.env</em> (for 3th full node of the public testnet builds)
- Fill the required fields as described in the "ENV files fields" section.

### List of npm commands regarding this deployer:

**<code>deploy--init--start_root-node-testnet-public-zone01</code>** - deploys, initializes and starts the root-validator of the public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--init--start_seed-node-testnet-public-zone01</code>** - deploys, initializes and starts the 1st seed node of the public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--init--start_sentry-node-testnet-public-zone01</code>** - deploys, initializes and starts the 1st sentry node of the public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--init_validator-node-testnet-public-zone02</code>** - deploys and initializes the validator-02 of the public testnet using <code>secrets.json</code> in the deployer's folder. <em>Unlike the root-validator, the validator-02 is only initialized and NOT started, because it MUST be configured before it can be start. The configuration can be made once its seeds and sentries are up and running. More about this in Deployment procedure section</em>

**<code>deploy--config--start_validator-node-testnet-public-zone02</code>** - deploys, configs and starts the validator-02 of the public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--init--start_seed-node-testnet-public-zone02</code>** - deploys, initializes and starts the 2nd seed node of the public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--init--start_sentry-node-testnet-public-zone02</code>** - deploys, initializes and starts the 2nd sentry node of the public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--init_validator-node-testnet-public-zone03</code>** - deploys and initializes the validator-03 of the public testnet using <code>secrets.json</code> in the deployer's folder. <em>Unlike the root-validator, the validator-03 is only initialized and NOT started, because it MUST be configured before it can be start. The configuration can be made once its seeds and sentries are up and running. More about this in Deployment procedure section</em>

**<code>deploy--config--start_validator-node-testnet-public-zone03</code>** - deploys, configs and starts the validator-03 of the public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--init--start_seed-node-testnet-public-zone03</code>** - deploys, initializes and starts the 3nd seed node of the public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--init--start_sentry-node-testnet-public-zone03</code>** - deploys, initializes and starts the 3nd sentry node of the public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--init--start_root-node-testnet-private</code>** - deploys, initializes and starts the root-validator of the private testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--init--start_seed-node-testnet-private</code>** - deploys, initializes and starts the seed node of the private testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--init--start_sentry-node-testnet-private</code>** - deploys, initializes and starts the sentry node of the private testnet using <code>secrets.json</code> in the deployer's folder.

## orchestrator deployer

### Usage:
1. Configure <code>secrets.json</code> in this deployer as described above.
2. Configure the ENV variables in <code>parentDir/CudosBuilders/docker/orchestator</code>
- Copy <em>orchestrator.env.example</em> to:
    - <em>orchestrator.testnet.private.env</em> (for private testnet builds)
    - <em>orchestrator.testnet.public.zone01.env</em> (for public testnet builds of the root-validator)
    - <em>orchestrator.testnet.public.zone02.env</em> (for public testnet builds of the validator-02)
    - <em>orchestrator.testnet.public.zone03.env</em> (for public testnet builds of the validator-03)
- Fill the required fields as described in the "ENV files fields" section.

### List of npm commands regarding this deployer:

**<code>deploy--orchestrator-testnet-private</code>** - deploys the orchestrator of root-validator of the private testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--orchestrator-testnet-public-zone01</code>** - deploys the orchestrator of root-validator of the public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--orchestrator-testnet-public-zone02</code>** - deploys the orchestrator of validator-02 of the public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>deploy--orchestrator-testnet-public-zone03</code>** - deploys the orchestrator of validator-03 of the public testnet using <code>secrets.json</code> in the deployer's folder.

## tsl deployer

The deployer contains only a readme file that explains how the server should be configured in order to suppost the Domain and TSL of sentry nodes. Currently this is has already been done for public testnet sentry nodes.

## utils deployer

### Usage:
1. Configure <code>secrets.json</code> in this deployer as described above.
2. Configure the ENV variables in <code>parentDir/CudosBuilders/docker/explorer</code>
- Copy <em>explorer.env.example</em> to:
    - <em>explorer.testnet.private.env</em> (for private testnet builds)
    - <em>explorer.testnet.public.env</em> (for public testnet builds)
- Fill the required fields as described in the "ENV files fields" section.
3. Configure the ENV variables in <code>parentDir/CudosBuilders/docker/faucet</code>
- Copy <em>faucet.env.example</em> to:
    - <em>faucet.testnet.private.env</em> (for private testnet builds)
    - <em>faucet.testnet.public.env</em> (for public testnet builds)
- Fill the required fields as described in the "ENV files fields" section.

### List of npm commands regarding this deployer:

**<code>deploy-utils-testnet-public</code>** - deploys utils (explorer + faucet) to public testnet using <code>secrets.json</code> in the deployer's folder.

**<code>ddeploy-utils-testnet-private</code>** - deploys utils (explorer + faucet) to private testnet using <code>secrets.json</code> in the deployer's folder.

# Setup docker (docker folder)

To do

# Using predefined scripts (.vscode folder)

To do

# Deployment procedure

To do

# Upgrade procedure

To do

# ENV files fields

Always copy the example .env.example file. You could leave the default values as they are and just add the required fields as described below in this section.

Please note the port of each endpoint. It can be used as indicator which endpoint is required.

## Explorer

- <code>MONGO_URL</code> - MongoDB connection string. It could be empty for dev builds.
- <code>ROOT_URL</code> - The URL where explorer will be access from. For example: ROOT_URL=http://localhost.

## Faucet

- <code>CREDIT_AMOUNT</code> - Default credit amount in acudos. It can safely be as MAX_CREDIT.
- <code>MAX_CREDIT</code> - Max credit amount in acudos.
- <code>NODE</code> - Cosmos URL. For example: NODE="http://localhost:26657".
- <code>MNEMONIC</code> - Mnemonic phrase of wallet that will be used to send tokens from.
- <code>GOOGLE_API_KEY</code> - Google Api Key for captcha enterprise.
- <code>CAPTCHA_SITE_KEY</code> - Google Site key for captcha enterprice.
- <code>GOOGLE_PROJECT_ID</code> - gcloud project id.

## Full node

- <code>MONIKER</code> - Name of the node.
- <code>PERSISTENT_PEERS</code> - List of comma separated persistent_peers in format <node_id@ip:26656>. Persistent peers are nodes that current node is always connected to.
- <code>SEEDS</code> - List of comma separated seeds in format <node_id@ip:26656>. Seeds are nodes that periodicly checks the network for active peers. When someone connects to them, they just send the list of the peers so that the recipient will connect to the returned peers.
- <code>SHOULD_USE_GLOBAL_PEERS</code> - Indicates whether this node should use peers from <code>parentDir/CudosBuilders/config</code> or this node should use the peers defined in this file.

## Gravity bridge ui

- <code>URL</code> - The URL where UI will be accessed. For example: URL=http://localhost.
- <code>CHAIN_ID</code> - ID of the cosmos chain.
- <code>RPC</code> - Endpoint of cosmos chain. For example: RPC=http://localhost:26657.
- <code>API</code> - Endpoint of cosmos chain api. For example: API=http://localhost:1317.
- <code>ERC20_CONTRACT_ADDRESS</code> - Ethereum token contract address.
- <code>BRIDGE_CONTRACT_ADDRESS</code> - Gravity Bridge contract address.
- <code>ETHEREUM_RPC</code> - Address of Ethereum full node. For example: http://12.13.14.15:8545. Do not use infura node.

## Gravity contract deployer

- <code>COSMOS_NODE</code> - The endpoint of cosmos chain. For example: COSMOS_NODE="http://localhost:26657"
- <code>ETH_NODE</code> - The endpoint of eth full node. For example: ETH_NODE="http://localhost:8545"
- <code>ETH_PRIV_KEY_HEX</code> - The private key of Ethereum wallet that will be used to sign the transaction for contract creation. It can be any Ethereum address that has enough tokens (~0.02ETH). Format is hex without leading "0x". For example: ETH_PRIV_KEY_HEX="a2b......"

## Orchestrator

- <code>FEES</code> - Amount of cudos that will be required by this validator in order to sign any operation. For example: FEES="1acudos"
- <code>GRPC</code> - The endpoint of cosmos chain. For example: COSMOS_NODE="http://localhost:9090"
- <code>ETHRPC</code> - The endpoint of eth full node. For example: ETH_NODE="http://localhost:8545"
- <code>CONTRACT_ADDR</code> - Gravity Bridge contract address.
- <code>COSMOS_ORCH_MNEMONIC</code> - Mnemonic phrase of orchestrator wallet.
- <code>ETH_PRIV_KEY_HEX</code> - The private key of Ethereum wallet that will be used to sign the transactions for sending funds from cosmos -> Ethereum. This wallet has been used to register the validator. Format is hex without leading "0x". For example: ETH_PRIV_KEY_HEX="a2b......".

## Root node

- <code>MONIKER</code> - Name of the node.
- <code>CHAIN_ID</code> - Random string without space.
- <code>ORCH_ETH_ADDRESS</code> - Ethereum address of a wallet that will be used to sign the transactions for sending funds from cosmos -> Ethereum. <em>This is the same wallet which adress should be used later on in orchestrator.env.example -> ETH_PRIV_KEY_HEX</em>.

## Seed node

- <code>MONIKER</code> - Name of the node.
- <code>PERSISTENT_PEERS</code> - List of comma separated persistent_peers in format <node_id@ip:26656>. Persistent peers are nodes that current node is always connected to.
- <code>PRIVATE_PEERS</code> - List of comma separated private peers in format <node_id@ip:26656>. Private peers are nodes that current node do not expose to anyone.
- <code>SHOULD_USE_GLOBAL_PEERS</code> - Indicates whether this node should use peers from <code>parentDir/CudosBuilders/config</code> or this node should use the peers defined in this file.

## Sentry node

- <code>MONIKER</code> - Name of the node.
- <code>PERSISTENT_PEERS</code> - List of comma separated persistent_peers in format <node_id@ip:26656>. Persistent peers are nodes that current node is always connected to.
- <code>PRIVATE_PEERS</code> - List of comma separated private peers in format <node_id@ip:26656>. Private peers are nodes that current node do not expose to anyone.
- <code>SEEDS</code> - List of comma separated seeds in format <node_id@ip:26656>. Seeds are nodes that periodicly checks the network for active peers. When someone connects to them, they just send the list of the peers so that the recipient will connect to the returned peers.
- <code>SHOULD_USE_GLOBAL_PEERS</code> - Indicates whether this node should use peers from <code>parentDir/CudosBuilders/config</code> or this node should use the peers defined in this file.
- <code>TLS_ENABLED</code> - This variable is used to indicate whether the sentry node will have an HTTPs domain. For example: TLS_ENABLED=true.
- <code>TLS_DOMAIN</code> - (Can be skipped if <code>TLS_ENABLED</code> is false). The domain of the sentry node.
- <code>TLS_DOCKER_PATH</code> - (Can be skipped if <code>TLS_ENABLED</code> is false). Path to letsencrypt.