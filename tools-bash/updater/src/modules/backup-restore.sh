#!/bin/bash -i

echo -ne "Creating backup lock file...";
echo "" > "$PARAM_SOURCE_DIR/.backup-restore.lock"
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

echo -ne "Removing source files...";
# rm -rf "$PARAM_SOURCE_DIR/CudosData"
rm -rf "$PARAM_SOURCE_DIR/CudosNode"
rm -rf "$PARAM_SOURCE_DIR/CudosGravityBridge"
rm -rf "$PARAM_SOURCE_DIR/CudosBuilders"
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

echo -ne "Restoring...";
# \cp -r "$PARAM_SOURCE_DIR/CudosData-backup" "$PARAM_SOURCE_DIR/CudosData"
\cp -r "$PARAM_SOURCE_DIR/CudosNode-backup" "$PARAM_SOURCE_DIR/CudosNode"
\cp -r "$PARAM_SOURCE_DIR/CudosGravityBridge-backup" "$PARAM_SOURCE_DIR/CudosGravityBridge"
\cp -r "$PARAM_SOURCE_DIR/CudosBuilders-backup" "$PARAM_SOURCE_DIR/CudosBuilders"
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

echo -ne "Releasing backup lock file...";
rm -f "$PARAM_SOURCE_DIR/.backup-restore.lock"
echo -e "${STYLE_GREEN}OK${STYLE_DEFAULT}";

