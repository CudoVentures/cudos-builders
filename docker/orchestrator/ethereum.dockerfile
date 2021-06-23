FROM ethereum/client-go:stable

RUN apk add --no-cache curl

# CMD ["sleep", "infinity"]

# COPY testdata/testchain/ETHGenesis.json ETHGenesis.json

ENTRYPOINT geth --rinkeby --syncmode "light" --http --http.port "8545" --http.addr "0.0.0.0" --http.corsdomain "*" --http.vhosts "*" --http.api personal,eth,net,web3

# RUN geth --identity "GravityTestnet" \
#     --nodiscover \
#     --networkid 15 init ETHGenesis.json

# ENTRYPOINT geth --identity "GravityTestnet" --nodiscover \
#            --networkid 15 \
#            --mine \
#            --http \
#            --http.port "8545" \
#            --http.addr "0.0.0.0" \
#            --http.corsdomain "*" \
#            --http.vhosts "*" \
#            --miner.threads=1 \
#            --nousb \
#            --verbosity=5 \
#            --miner.etherbase=0xBf660843528035a5A4921534E156a27e64B231fE