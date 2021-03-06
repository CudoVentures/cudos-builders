#!/bin/bash -i

if [ -f "$LOCK_UPGRADE_PATH" ]; then
    echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} There is unfinished upgrade. Please restore the source files from a backup using sudo ./src/backup.sh restore and re-run the upgrade";
    exit 1;
fi

if [ "$action" = "upgrade" ]; then
    if [ ! -f "$LOCK_VALIDATE_PATH" ]; then
        echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} Run the ${STYLE_BOLD}validate${STYLE_DEFAULT} before the ${STYLE_BOLD}upgrade${STYLE_DEFAULT}";
        exit 1;
    fi

    timestamp=$(date '+%s')
    validateTimestamp=$(cat "$LOCK_VALIDATE_PATH")

    oldValidate=$(("$timestamp"-"$validateTimestamp" > 3600))
    if [ "$oldValidate" = "1" ]; then
        echo -e "${STYLE_RED}Error:${STYLE_DEFAULT} Run the ${STYLE_BOLD}validate${STYLE_DEFAULT} before the ${STYLE_BOLD}upgrade${STYLE_DEFAULT}";
        exit 1;
    fi
fi

source "$WORKING_SRC_DIR/incs/validate-params.sh"

source "$WORKING_SRC_DIR/incs/validate-network.sh"

source "$WORKING_SRC_DIR/incs/validate-folders.sh" "validate"

source "$WORKING_SRC_DIR/incs/validate-version.sh"

source "$WORKING_SRC_DIR/incs/validate-chain-id.sh"

echo "" # new line

echo -e "${STYLE_BOLD}CURRENT NETWORK INFORMATION:${STYLE_DEFAULT}"
echo -e "${STYLE_BOLD}Network:${STYLE_DEFAULT} $NETWORK_NAME"
echo -e "${STYLE_BOLD}Version:${STYLE_DEFAULT} $UPDATE_FROM_VERSION"
echo -e "${STYLE_BOLD}Node name:${STYLE_DEFAULT} $PARAM_NODE_NAME"
echo -e "${STYLE_BOLD}Node's .env path:${STYLE_DEFAULT} $NODE_ENV_PATH"
if [ "$HAS_ORCHESTRATOR" = "true" ]; then
    echo -e "${STYLE_BOLD}Orchestrator's .env path:${STYLE_DEFAULT} $ORCHESTRATOR_ENV_PATH"
fi

if [ "$action" = "validate" ]; then
    echo "" # new line
    echo -e "${STYLE_BOLD}Do NOT run the upgrade if any of the above information is incorrect${STYLE_DEFAULT}"

    timestamp=$(date '+%s')
    echo "$timestamp" > "$LOCK_VALIDATE_PATH"
fi
