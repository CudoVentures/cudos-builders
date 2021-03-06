#!/bin/bash -i

function readEnvFromString {
    envAsString="$1"
    envName="$2"
    tmpFilePath="/tmp/cudos-launcher-string.env"

    echo "$1" > "$tmpFilePath"
    eval $(source "$tmpFilePath"; echo tmpEnv="\"${!envName}\"")
    echo "$tmpEnv"
    unset tmpEnv
    rm -f "$tmpFilePath"
}

function joinBy {
    local d=${1-} f=${2-}
    if shift 2; then
      printf %s "$f" "${@/#/$d}"
    fi
}
