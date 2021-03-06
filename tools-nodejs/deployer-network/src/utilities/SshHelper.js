const { NodeSSH } = require('node-ssh');
const Log = require('./LogHelper');
const PathHelper = require('./PathHelper');

class SshHelper {

    constructor(computer, stdLog = true) {
        this.computer = computer;
        this.stdLog = stdLog;
        this.ssh = new NodeSSH();
    }

    async connect() {
        const params = {
            host: this.computer.ip,
            port: this.computer.port,
            username: this.computer.user,
        };

        if (this.computer.hasSshKey() === false) {
            params.password = this.computer.pass;
        } else {
            params.privateKey = this.computer.sshKey;
            params.passphrase = this.computer.pass;
        }

        await this.ssh.connect(params);

        Log.main(`Connected to ${this.computer.ip}:${this.computer.port}`);
    }

    async disconnect() {
        this.ssh.dispose();
        Log.main(`Disconnect from ${this.computer.ip}:${this.computer.port}`);
    }

    async exec(cmd, stdLog) {
        if (Array.isArray(cmd)) {
            cmd = cmd.join(' && ');
        }

        stdLog = stdLog ?? this.stdLog;

        const res = [];
        try {
            await this.ssh.exec(cmd, [], {
                onStdout: (chunk) => {
                    const log = chunk.toString('utf8').trim();
                    res.push(log);
                    if (stdLog === true) {
                        Log.ssh(log);
                    }
                },
                onStderr: (chunk) => {
                    const log = chunk.toString('utf8').trim();
                    res.push(log);
                    if (stdLog === true) {
                        Log.ssh(log);
                    }
                },
            });
        } catch (ex) {
        }

        return res.join('\n');
    }

    async cloneRepos() {
        await this.exec([
            `cd ${PathHelper.WORKING_DIR}`,
            'rm -rf ./CudosNode',
            'rm -rf ./CudosBuilders',
            'rm -rf ./CudosGravityBridge',
            'rm -rf ./CudosGravityBridgeUI',
            'rm -rf ./CudosExplorer',
            'rm -rf ./CudosFaucet',
            'git clone --depth 1 --branch cudos-master https://github.com/CudoVentures/cudos-node.git CudosNode',
            'git clone --depth 1 --branch cudos-master https://github.com/CudoVentures/cudos-builders.git CudosBuilders',
            'git clone --depth 1 --branch cudos-master https://github.com/CudoVentures/cosmos-gravity-bridge.git CudosGravityBridge',
            'git clone --depth 1 --branch cudos-master https://github.com/CudoVentures/cudos-gravity-bridge-ui CudosGravityBridgeUI',
            'git clone --depth 1 --branch cudos-master https://github.com/CudoVentures/big-dipper.git CudosExplorer',
            'git clone --depth 1 --branch cudos-master https://github.com/CudoVentures/faucet.git CudosFaucet'
        ]);
    }

    async prepareBinaryBuilder() {
        const imageId = await this.exec('docker images -q binary-builder', false);
        if (imageId !== '') {
            return;
        }

        await this.exec([
            `cd ${PathHelper.WORKING_DIR}/CudosBuilders/docker/binary-builder`,
            'docker-compose --env-file ./binary-builder.arg -f ./binary-builder.yml -p cudos-binary-builder build',
        ]);
    }

    awaitForNode(dockerContainerName) {
        return new Promise((resolve, reject) => {
            const runnable = async () => {
                const statusString = await this.exec(`docker container exec ${dockerContainerName} /bin/bash -c "cudos-noded status"`, false);
                try {
                    const status = JSON.parse(statusString);
                    if (status.SyncInfo.catching_up === false) {
                        clearInterval(intervalHandler);
                        resolve();
                    }
                } catch (ex) {
                }
            };
            
            const intervalHandler = setInterval(runnable, 1000);
        });
    }

    awaitForTx(dockerContainerName, txResultString) {
        return new Promise((resolve, reject) => {
            const txResult = JSON.parse(txResultString);
            const blockHeight = parseInt(txResult.height) + 1;

            const runnable = async () => {
                const statusString = await this.exec(`docker container exec ${dockerContainerName} /bin/bash -c "cudos-noded status"`, false);
                try {
                    const status = JSON.parse(statusString);
                    if (parseInt(status.SyncInfo.latest_block_height) >= blockHeight) {
                        clearInterval(intervalHandler);
                        resolve();
                    }
                } catch (ex) {
                    console.log('error waiting for block', ex);
                }
            };
            
            const intervalHandler = setInterval(runnable, 5000);
        });
    }

}

module.exports = SshHelper;