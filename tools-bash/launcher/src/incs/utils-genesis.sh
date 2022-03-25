#!/bin/bash -i

function sum {
    cat "$1" | python3 -c "import json, sys; print(sum(map(lambda x: int(x), json.load(sys.stdin))))"
}

function calculateGravityModuleBalance {
    python3 -c "import json, sys; print(10000000000000000000000000000 - 134949630643200000000000000 - $1 - $2)"
}

function getModuleAddress {
    result=$(jq .app_state.auth.accounts "$1" | jq "map(select(.name == \"$2\") | .base_account.address)" | jq ".[0]")
    echo ${result//\"/}
}

function getAccountBalanceInAcudos {
    tmpPath="/tmp/getAccountBalanceInAcudos"
    
    jq .app_state.bank.balances "$1" | jq "map(select(.address == \"$2\") | .)" > "$tmpPath"
    size=$(jq length "$tmpPath")

    balance="0"
    if [ "$size" = "1" ]; then
        balance=$(jq .[0].coins[0].amount "$tmpPath")
        balance=${balance//\"/}
    fi

    rm -f "$tmpPath"
    echo $balance
}

function getRewardByAddress {
    tmpPath="/tmp/getRewardByAddress"

    jq ".bank | map(select(.address == \"$1\") | .)" "$STAKING_JSON" > "$tmpPath"
    validatorRewardsSize=$(jq length "$tmpPath")
    validatorReward="0"
    if [ "$validatorRewardsSize" != "0" ]; then
        if [ "$validatorRewardsSize" != "1" ]; then
            rm -f "$tmpPath"
            exit 1;
        fi

        validatorReward=$(jq .[0].balance "$tmpPath")
        validatorReward=${validatorReward//\"/}
    fi

    rm -f "$tmpPath"
    echo $validatorReward
}

function addAuthAccountIfNotExists {
    tmpPath="/tmp/addAuthAccountIfNotExists"

    jq .app_state.auth.accounts "$1" | jq "map(select(.address == \"$2\") | .)" > "$tmpPath"
    size=$(jq length "$tmpPath")
    if [ "$size" = "0" ]; then
        result=$(jq ".app_state.auth.accounts += [{
            \"@type\": \"/cosmos.auth.v1beta1.BaseAccount\", 
            account_number: \"0\", 
            address: \"$2\", 
            pub_key: null, 
            sequence: \"1\"
        }]" "$1")
        echo $result > "$1"
    fi

    rm -f "$tmpPath"
}

function setAccountBalanceInAcudosWithoutAuthAccount {
    tmpPath="/tmp/setAccountBalanceInAcudos"

    jq .app_state.bank.balances "$1" | jq "map(select(.address == \"$2\") | .)" > "$tmpPath"
    size=$(jq length "$tmpPath")
    rm -f "$tmpPath"

    if [ "$size" != "0" ] && [ "$size" != "1" ]; then
        echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There are several balances for account: $2";
        exit 1;
    fi

    if [ "$size" = "0" ]; then
        result=$(jq ".app_state.bank.balances += [{
            \"address\": \"$2\",
            \"coins\": [
                {
                \"amount\": \"$3\",
                \"denom\": \"acudos\"
                }
            ]
        }]" "$1")
        echo $result > "$1"
    fi

    if [ "$size" = "1" ]; then
        result=$(jq ".app_state.bank.balances = [.app_state.bank.balances[] | if (.address == \"$2\") then (.coins[0].amount = \"$3\") else . end]" "$1")
        echo $result > "$1"
    fi
}

function setAccountBalanceInAcudos {
    addAuthAccountIfNotExists "$1" "$2"
    setAccountBalanceInAcudosWithoutAuthAccount "$1" "$2" "$3"
}

function setAccountBalanceInCudosAdmin {
    tmpPath="/tmp/setAccountBalanceInCudosAdmin"

    addAuthAccountIfNotExists "$1" "$2"

    jq .app_state.bank.balances "$1" | jq "map(select(.address == \"$2\") | .)" > "$tmpPath"
    size=$(jq length "$tmpPath")
    rm -f "$tmpPath"

    if [ "$size" != "0" ] && [ "$size" != "1" ]; then
        echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There are several balances for account: $2";
        exit 1;
    fi

    if [ "$size" = "0" ]; then
        result=$(jq ".app_state.bank.balances += [{
            \"address\": \"$2\",
            \"coins\": [
                {
                \"amount\": \"$3\",
                \"denom\": \"cudosAdmin\"
                }
            ]
        }]" "$1")
        echo $result > "$1"
    fi

    if [ "$size" = "1" ]; then
        result=$(jq ".app_state.bank.balances = [.app_state.bank.balances[] | if (.address == \"$2\") then (.coins += [{
                amount: \"$3\",
                denom: \"cudosAdmin\"
            }]) else . end]" "$RESULT_GENESIS_PATH")
        echo $result > "$1"
    fi
}

function addDelegatorsAccountsAndBalances {
    delegatorsSize=$(jq length "$1")
    for i in $(seq 0 $(($delegatorsSize-1))); do
        delegatorAddress=$(jq ".[$i].delegatorAddress" "$1")
        delegatorAddress=${delegatorAddress//\"/}

        delegatorReward=$(getRewardByAddress "$delegatorAddress")
        if [ "$?" != "0" ]; then 
            echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} More than a single reward for a delegator: $delegatorAddress";
            exit 1
        fi

        setAccountBalanceInAcudos "$RESULT_GENESIS_PATH" "$delegatorAddress" "$delegatorReward"
    done;
}