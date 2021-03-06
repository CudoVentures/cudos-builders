#!/bin/bash

echo "Setting up config.toml"
cp /usr/hermes/config.toml /root/.hermes/config.toml

# relayer REST settings
sed -zi "s/\nenabled = [^\n]*\n/\nenabled = ${REST_ENABLED}\n/1" "/root/.hermes/config.toml"
sed -zi "s/\nhost = '[^']*'/\nhost = '${REST_HOST}'/1" "/root/.hermes/config.toml"
sed -zi "s/\nport = [^\n]*\n/\nport = ${REST_PORT}\n/1" "/root/.hermes/config.toml"

# relayer TELEMETRY settings
sed -zi "s/\nenabled = [^\n]*\n/\nenabled = ${TELEMETRY_ENABLED}\n/2" "/root/.hermes/config.toml"
sed -zi "s/\nhost = '[^']*'/\nhost = '${TELEMETRY_HOST}'/2" "/root/.hermes/config.toml"
sed -zi "s/\nport = [^\n]*\n/\nport = ${TELEMETRY_PORT}\n/2" "/root/.hermes/config.toml"

# chain 1 settings
sed -zi "s/\nid = '[^']*'/\nid = '${CHAIN_ID_0}'/1" "/root/.hermes/config.toml"
sed -zi "s/\nrpc_addr = '[^']*'/\nrpc_addr = '${RPC_ADDR_0}'/1" "/root/.hermes/config.toml"
sed -zi "s/\ngrpc_addr = '[^']*'/\ngrpc_addr = '${GRPC_ADDR_0}'/1" "/root/.hermes/config.toml"
sed -zi "s/\nwebsocket_addr = '[^']*'/\nwebsocket_addr = '${WEBSOCKET_ADDR_0}'/1" "/root/.hermes/config.toml"
sed -zi "s/\naccount_prefix = '[^']*'/\naccount_prefix = '${ACCOUNT_PREFIX_0}'/1" "/root/.hermes/config.toml"
sed -zi "s/\nkey_name = '[^']*'/\nkey_name = '${CHAIN_ID_0}_key'/1" "/root/.hermes/config.toml"
sed -zi "s/{ price = [^,]*/{ price = ${GAS_PRICE_0}/1" "/root/.hermes/config.toml"
sed -zi "s/denom = '[^']*'/denom = '${GAS_DENOM_0}'/1" "/root/.hermes/config.toml"
sed -zi "s/trusting_period = '[^']*'/trusting_period = '${TRUSTING_PERIOD_0}'/1" "/root/.hermes/config.toml"

# chain 2 settings
sed -zi "s/\nid = '[^']*'/\nid = '${CHAIN_ID_1}'/2" "/root/.hermes/config.toml"
sed -zi "s/\nrpc_addr = '[^']*'/\nrpc_addr = '${RPC_ADDR_1}'/2" "/root/.hermes/config.toml"
sed -zi "s/\ngrpc_addr = '[^']*'/\ngrpc_addr = '${GRPC_ADDR_1}'/2" "/root/.hermes/config.toml"
sed -zi "s/\nwebsocket_addr = '[^']*'/\nwebsocket_addr = '${WEBSOCKET_ADDR_1}'/2" "/root/.hermes/config.toml"
sed -zi "s/\naccount_prefix = '[^']*'/\naccount_prefix = '${ACCOUNT_PREFIX_1}'/2" "/root/.hermes/config.toml"
sed -zi "s/\nkey_name = '[^']*'/\nkey_name = '${CHAIN_ID_1}_key'/2" "/root/.hermes/config.toml"
sed -zi "s/{ price = [^,]*/{ price = ${GAS_PRICE_1}/2" "/root/.hermes/config.toml"
sed -zi "s/denom = '[^']*'/denom = '${GAS_DENOM_1}'/2" "/root/.hermes/config.toml"
sed -zi "s/trusting_period = '[^']*'/trusting_period = '${TRUSTING_PERIOD_1}'/2" "/root/.hermes/config.toml"


echo "Setting up wallets for each chain"
hermes keys restore ${CHAIN_ID_0} -m "${MNEMONIC_0}"
hermes keys restore ${CHAIN_ID_1} -m "${MNEMONIC_1}"

#init
if [ "$CREATE_CHANNEL" = true ] ; then
    echo "Creating channel"
    hermes create connection ${CHAIN_ID_0} ${CHAIN_ID_1} | tee /root/.hermes/create-channel-data.txt
    ERR=$(cat /root/.hermes/create-channel-data.txt | grep "error")

    if [ "$ERR" == "" ]; then 
        CONNECTION_ID_A=$(cat /root/.hermes/create-channel-data.txt | grep "Success: Connection" -A 100 | grep \"connection -m 1) 

        CONNECTION_ID_A=${CONNECTION_ID_A//\"/}
        CONNECTION_ID_A=${CONNECTION_ID_A//\,/}

        hermes create channel --port-a transfer --port-b transfer ${CHAIN_ID_0} ${CONNECTION_ID_A} | tee -a /root/.hermes/create-channel-data.txt 
    fi
fi
