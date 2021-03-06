if [[ -z "${CUDOS_HOME}" ]]; then
    CUDOS_HOME="./cudos-data"
fi

if [ "$SHOULD_USE_GLOBAL_PEERS" = "true" ]; then
    PERSISTENT_PEERS=$(cat ./external-config/persistent-peers.config)
    SEEDS=$(cat ./external-config/seeds.config)
fi

WORKING_PATH=$(pwd) && cd $CUDOS_HOME && rm -Rf ./* && cd $WORKING_PATH
BOND_DENOM="acudos"

cudos-noded init $MONIKER

cp ./external-config/genesis.json "${CUDOS_HOME}/config/genesis.json"

# gas price
sed -i "s/minimum-gas-prices = \"\"/minimum-gas-prices = \"5000000000000${BOND_DENOM}\"/" "${CUDOS_HOME}/config/app.toml"

# for port 1317
# eanble
sed -i "/\[api\]/,/\[/ s/enable = false/enable = true/" "${CUDOS_HOME}/config/app.toml"
sed -i "s/enabled-unsafe-cors = false/enabled-unsafe-cors = true/" "${CUDOS_HOME}/config/app.toml"
# disable
# sed -i "/\[api\]/,/\[/ s/enable = true/enable = false/" "${CUDOS_HOME}/config/app.toml"

# port 9090
# enable
sed -i "/\[grpc\]/,/\[/ s/enable = false/enable = true/" "${CUDOS_HOME}/config/app.toml"
# disable
# sed -i "/\[grpc\]/,/\[/ s/enable = true/enable = false/" "${CUDOS_HOME}/config/app.toml"

# for port 26657
sed -i "s/laddr = \"tcp:\/\/127.0.0.1:26657\"/laddr = \"tcp:\/\/0.0.0.0:26657\"/" "${CUDOS_HOME}/config/config.toml"
sed -i "s/cors_allowed_origins = \[\]/cors_allowed_origins = \[\"\*\"\]/" "${CUDOS_HOME}/config/config.toml"
# disable
# sed -i "s/laddr = \"tcp:\/\/0.0.0.0:26657\"/laddr = \"tcp:\/\/127.0.0.1:26657\"/" "${CUDOS_HOME}/config/config.toml"
# sed -i "s/cors_allowed_origins = .*/cors_allowed_origins = \[\]/" "${CUDOS_HOME}/config/config.toml"

# monitoring
# port 26660
if [ "${MONITORING_ENABLED}" = "true" ]; then
    sed -i "s/prometheus = .*/prometheus = true/g" "${CUDOS_HOME}/config/config.toml"
fi
if [ "${MONITORING_ENABLED}" = "false" ]; then
    sed -i "s/prometheus = .*/prometheus = false/g" "${CUDOS_HOME}/config/config.toml"
fi

sed -i "s/persistent_peers = \".*\"/persistent_peers = \"$PERSISTENT_PEERS\"/g" "${CUDOS_HOME}/config/config.toml"

sed -i "s/seeds = \".*\"/seeds = \"$SEEDS\"/g" "${CUDOS_HOME}/config/config.toml"

sed -i "s/private_peer_ids = \".*\"/private_peer_ids = \"$PRIVATE_PEERS\"/g" "${CUDOS_HOME}/config/config.toml"

sed -i "s/unconditional_peer_ids = \".*\"/unconditional_peer_ids = \"$PRIVATE_PEERS\"/g" "${CUDOS_HOME}/config/config.toml"

# TLS cert
if [ "${TLS_ENABLED}" = "true" ]; then
    sed -i "s|tls_cert_file = \".*\"|tls_cert_file = \"$TLS_DOCKER_PATH/live/$TLS_DOMAIN/fullchain.pem\"|g" "${CUDOS_HOME}/config/config.toml"
    sed -i "s|tls_key_file = \".*\"|tls_key_file = \"$TLS_DOCKER_PATH/live/$TLS_DOMAIN/privkey.pem\"|g" "${CUDOS_HOME}/config/config.toml"
fi

if [ "${EXTERNAL_ADDRESS}" != "" ]; then
    sed -i "s/external_address = \"\"/external_address = \"${EXTERNAL_ADDRESS}\"/g" "${CUDOS_HOME}/config/config.toml"
fi

if [ "${ADDR_BOOK_STRICT}" = "false" ]; then
    sed -i "s/addr_book_strict = true/addr_book_strict = false/g" "${CUDOS_HOME}/config/config.toml"
fi

# STATE SYNC
if [ "$SHOULD_USE_STATE_SYNC" = "true" ]; then
    STATE_SYNC_RPC_SERVERS=$(cat ./external-config/state-sync-rpc-servers.config)
    IFS=', ' read -r -a STATE_SYNC_RPC_SERVERS_ARRAY <<< ${STATE_SYNC_RPC_SERVERS}
    
    TEMP_STATE_HEIGHT=$(curl -s ${STATE_SYNC_RPC_SERVERS_ARRAY[0]}/commit | jq -r ".result.signed_header.header.height")
    STATE_SYNC_HEIGHT=$(((($TEMP_STATE_HEIGHT/2000)-1)*2000))
    STATE_SYNC_HASH=$(curl -s ${STATE_SYNC_RPC_SERVERS_ARRAY[0]}/commit?height=${STATE_SYNC_HEIGHT} | jq '.result.signed_header.commit.block_id.hash')

    HASHES_MATCH=true
    for SERVER in "${STATE_SYNC_RPC_SERVERS_ARRAY[0]}"
    do
        TEMP_HASH=$(curl -s ${SERVER}/commit?height=${STATE_SYNC_HEIGHT} | jq '.result.signed_header.commit.block_id.hash')
        if [ "$STATE_SYNC_HASH" != "$TEMP_HASH" ]; then
            HASHES_MATCH=false
            break
        fi
    done

    if [ "$HASHES_MATCH" = "true" ]; then
        sed -i "s/enable = false/enable = true/g" "${CUDOS_HOME}/config/config.toml"
        sed -i "s~rpc_servers = \".*\"~rpc_servers = \"${STATE_SYNC_RPC_SERVERS}\"~g" "${CUDOS_HOME}/config/config.toml"
        sed -i "s/trust_height = 0/trust_height = ${STATE_SYNC_HEIGHT}/g" "${CUDOS_HOME}/config/config.toml"
        sed -i "s/trust_hash = \".*\"/trust_hash = ${STATE_SYNC_HASH}/g" "${CUDOS_HOME}/config/config.toml"
    else
        echo "Hashed from different peers don't match. State sync is OFF"
    fi
fi


cudos-noded tendermint show-node-id |& tee "${CUDOS_HOME}/tendermint.nodeid"
