#!/usr/bin/env bash
# ==========================================================================
#  Snapshot-UI — Delete Script
#  Removes the container, image, and all associated Docker resources.
# ==========================================================================

set -e

CONTAINER_NAME="snapshot-ui"
IMAGE_NAME="snapshot-ui"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

echo ""
echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${RED}${BOLD}║          Snapshot-UI  ·  Delete Everything               ║${RESET}"
echo -e "${RED}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${YELLOW}  This will remove:${RESET}"
echo -e "${YELLOW}    • The '${CONTAINER_NAME}' container${RESET}"
echo -e "${YELLOW}    • The '${IMAGE_NAME}' Docker image${RESET}"
echo -e "${YELLOW}    • Any dangling volumes and build cache related to it${RESET}"
echo ""
read -p "$(echo -e "${RED}  Are you sure? [y/N]: ${RESET}")" confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "  Cancelled."
    echo ""
    exit 0
fi

echo ""

# ── Stop and remove container ────────────────────────────────────────
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${BOLD}  Removing container '${CONTAINER_NAME}'...${RESET}"
    docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1
    echo -e "${GREEN}  ✓ Container removed.${RESET}"
else
    echo -e "${DIM}  Container '${CONTAINER_NAME}' not found (already removed).${RESET}"
fi

# ── Remove image ─────────────────────────────────────────────────────
if docker images --format '{{.Repository}}' | grep -q "^${IMAGE_NAME}$"; then
    echo -e "${BOLD}  Removing image '${IMAGE_NAME}'...${RESET}"
    docker rmi -f "$IMAGE_NAME" > /dev/null 2>&1
    echo -e "${GREEN}  ✓ Image removed.${RESET}"
else
    echo -e "${DIM}  Image '${IMAGE_NAME}' not found (already removed).${RESET}"
fi

# ── Prune dangling volumes and build cache ───────────────────────────
echo -e "${BOLD}  Pruning dangling volumes...${RESET}"
docker volume prune -f > /dev/null 2>&1
echo -e "${GREEN}  ✓ Dangling volumes pruned.${RESET}"

echo -e "${BOLD}  Pruning build cache...${RESET}"
docker builder prune -f > /dev/null 2>&1
echo -e "${GREEN}  ✓ Build cache pruned.${RESET}"

echo ""
echo -e "${GREEN}${BOLD}  ✓  Snapshot-UI fully removed.${RESET}"
echo -e "${DIM}  To reinstall, run: ./setup.sh${RESET}"
echo ""
