#!/bin/bash -i

launcherPath=$(basename $(pwd))
if [ "$launcherPath" != "constructor" ]; then
    echo -e "\033[1;31mError:\033[m The script MUST be executed from constructor folder";
    exit 1
fi

source "./src/incs/args.sh" $@
if [ "$?" != 0 ]; then
    exit $?;
fi;

source "./src/incs/var.sh"
if [ "$?" != 0 ]; then
    exit $?;
fi;

source "$WORKING_SRC_DIR/incs/validate.sh"
if [ "$?" != 0 ]; then
    exit $?;
fi;

source "$WORKING_SRC_DIR/modules/repos.sh"
if [ "$?" != 0 ]; then
    exit $?;
fi;

source "$WORKING_SRC_DIR/modules/init-node.sh"
if [ "$?" != 0 ]; then
    exit $?;
fi;

source "$WORKING_SRC_DIR/modules/export-gentx.sh"
if [ "$?" != 0 ]; then
    exit $?;
fi;

echo "You MUST NOT delete the constructor script nor the destination folder where node's data is. They will be used later on for starting the nodes.";