#!/bin/bash -i

echo "$VALIDATOR_TENEDRMINT_NODE_ID" > "$WORKING_EXPORT_DIR/validator.tendermint.nodeid"
echo "$SEEDS_PUBLIC_PEERS_LIST" > "$WORKING_EXPORT_DIR/seed-node.tendermint.nodeid"
echo "$SENTRIES_PUBLIC_PEERS_LIST" > "$WORKING_EXPORT_DIR/sentry-node.tendermint.nodeid"
echo -e "$ORCHESTRATOR_MNEMONICS_LIST" > "$WORKING_EXPORT_DIR/orchs.mnemonic"

echo -e "Validator node ID is: ${STYLE_BOLD}${VALIDATOR_TENEDRMINT_NODE_ID}${STYLE_DEFAULT}";
echo -e "Seed node IDs are: ${STYLE_BOLD}${SEEDS_PUBLIC_PEERS_LIST}${STYLE_DEFAULT}";
echo -e "Sentry node IDs are: ${STYLE_BOLD}${SENTRIES_PUBLIC_PEERS_LIST}${STYLE_DEFAULT}";
# echo -e "Orchestrator mnemonics are:\n${STYLE_BOLD}${ORCHESTRATOR_MNEMONICS_LIST}${STYLE_DEFAULT}";
echo -e "Genesis file is saved to: ${STYLE_BOLD}${RESULT_GENESIS_PATH}${STYLE_DEFAULT}"

echo "" # new line

echo -e "These values can always be found at ${STYLE_BOLD}${WORKING_EXPORT_DIR}${STYLE_DEFAULT}";
