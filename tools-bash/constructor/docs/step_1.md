# Phase 4 instructions Step 1

This section describes the first steps needed for validator setup as part of the Phase 4 testnet launch.

## Prerequisites
Check all the needed prerequisites [here](./prerequisites.md).
### Setup the environment
You need to have a local copy of our build tools.Create your main Cudos directory. On the first row you can define where all Cudos data will be stored.

```
mkdir /usr/cudos

cd $HOME
git clone --branch cudos-master https://github.com/CudoVentures/cudos-builders.git CudosBuilders
```

## Nodes initialization

### Initialize the Validator
Go into the newly created CudosBuilders directory and make sure the init.sh can be executed.
```
cd CudosBuilders
sudo chmod +x ./tools-bash/constructor/src/init.sh
```

Copy the init.env.example and rename it to init.env. 
```
cp init.env.example init.env
```
Enter the newly copied file with the command below:
```
nano init.env
```
Then enter the following:

```
PARAM_SOURCE_DIR="/usr/cudos" 
PARAM_VALIDATOR_MNEMONIC="<KEY>" 
PARAM_KEYRING_OS_PASS="<PASS>"
PARAM_COMMISSION_RATE="0.10" 
PARAM_COMMISSION_MAX_RATE="0.20" 
PARAM_COMMISSION_MAX_CHANGE_RATE="0.01" 
```

**PARAM_SOURCE_DIR** is where the repos will be cloned and the binary compiled. It should be an existing and empty folder. The same you created above.

**PARAM_VALIDATOR_MNEMONIC** is the private key of the account you want to use for your validator.

**PARAM_KEYRING_OS_PASS** is the password of your keyring.

**PARAM_COMMISSION_RATE** is commission rate of the validator. Must be between 0 and the validator's PARAM_COMMISSION_MAX_RATE.

**PARAM_COMMISSION_MAX_RATE**  Can't be changed later.

**PARAM_COMMISSION_MAX_CHANGE_RATE** Can't be changed later.

NOTE: It is advisable you do NOT use your mainnet mnemonic for the test phase.


Copy the node.env.example and rename it to node.env. 
```
cp node.env.example node.env
```
Enter the newly copied file with the command below:
```
nano node.env
```
Then enter the following:

```
MONIKER="<name of the node>"
```


**Now it's time to init your node.**

```
cd ${HOME}/CudosBuilders/tools-bash/constructor
./src/init.sh clustered-validator-node
```

The command will use the configuration you have setup in the previous step and build the needed binaries. Successful run should print something like:
<img src="./init-full.png">

<!--
If you see any additional messages or error please refer to the troubleshooting section.
-->

## Genesis submission

Once your validator is running you should get it's genesis. It is located under ${CUDOS_DIR}/tools-bash/constructor/exports on your machine. To get the file of the you can use

```
GENESIS=$(ls $HOME/CudosBuilders/tools-bash/constructor/exports)
cat $GENESIS
```
Once you get the file contents send them as a **json** file to the Cudos team via email to [services@cudoventures.com](mailto:services@cudoventures.com).

# Things to keep in mind
1. The folder you use for a node needs to be created and empty. You will get errors otherwise.
2. If you are running more than one node on the same server, you might not be able to create the docker because they will try to open the same ports.

<!--
# Troubleshooting
-->