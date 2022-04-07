#!/bin/bash -i

if ([ $# != "1" ]) || ([ "$1" != "start" ] && [ "$1" != "validate" ]); then
    echo -e "\033[1;31mError:\033[m Please follow the usage template below";
    echo "Usage: sudo $0 [action]";
    echo '[action] = start | validate';
    exit 1
fi

action="$1"

if [ "$EUID" -ne 0 ]; then
    echo -e "\033[1;31mError:\033[m The script MUST be executed as root";
    exit 1
fi

updaterPath=$(basename $(pwd))
if [ "$updaterPath" != "updater" ]; then
    echo -e "\033[1;31mError:\033[m The script MUST be executed from updater folder";
    exit 1
fi

source "./src/incs/var.sh"

source "$WORKING_SRC_DIR/incs/utils.sh"

source "$WORKING_SRC_DIR/incs/validate-upgrade.sh"

if [ "$action" = "start" ]; then
    echo "" > "$LOCK_UPGRADE_PATH"

    echo "" # new line

    source "$WORKING_SRC_DIR/modules/emergency-backup.sh"

    if [ "$DO_HARD_FORK" = "true" ]; then
        source "$WORKING_SRC_DIR/modules/genesis-export.sh"
    fi

    source "$WORKING_SRC_DIR/modules/update-repos.sh"

    if [ "$DO_HARD_FORK" = "true" ]; then
        source "$WORKING_SRC_DIR/modules/genesis-migrate.sh"
    fi

    source "$WORKING_SRC_DIR/modules/start.sh"
fi

# export

# migrate

if [ "$action" = "validate" ]; then
    echo "" # new line

    echo -ne "Validating...";
fi
if [ "$action" = "start" ]; then
    rm -f "$LOCK_UPGRADE_PATH"

    echo "" # new line

    echo -e "Emergency data stores to ${STYLE_BOLD}$WORKING_EMERGENCY_BACKUP_DIR${STYLE_DEFAULT}. It can safely be deleted if the node is producing blocks after the upgrade."

    echo "" # new line

    echo -ne "Upgrading...";
fi
echo -e "${STYLE_GREEN}DONE${STYLE_DEFAULT}";
