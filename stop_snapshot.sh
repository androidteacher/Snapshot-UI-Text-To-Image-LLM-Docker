#!/usr/bin/env bash
# ==========================================================================
#  Snapshot-UI — Stop Script
#  Stops the running Snapshot-UI container.
# ==========================================================================

set -e

CONTAINER_NAME="snapshot-ui"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

echo ""

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}  Container '${CONTAINER_NAME}' is not running.${RESET}"
    echo ""
    exit 0
fi

echo -e "${BOLD}  Stopping container '${CONTAINER_NAME}'...${RESET}"
docker stop "$CONTAINER_NAME"

echo ""
echo -e "${GREEN}${BOLD}  ✓  Snapshot-UI stopped.${RESET}"
echo -e "${DIM}  To start it again: docker start ${CONTAINER_NAME}${RESET}"
echo -e "${DIM}  To rebuild from scratch: ./setup.sh${RESET}"
echo ""
