#!/usr/bin/env bash
# ==========================================================================
#  Snapshot-UI Setup Script
#  Builds the Docker image with the SDXS-512-0.9 OpenVINO model pre-baked.
# ==========================================================================

set -e

IMAGE_NAME="snapshot-ui"
CONTAINER_NAME="snapshot-ui"
PORT=9999

# Colors
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}║              Snapshot-UI  ·  Setup Script                ║${RESET}"
echo -e "${CYAN}${BOLD}║          Text-to-Image  ·  SDXS-512 OpenVINO            ║${RESET}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

# ── Check Docker ──────────────────────────────────────────────────────────
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed or not in PATH.${RESET}"
    echo "  Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

echo -e "${GREEN}✓${RESET} Docker found: $(docker --version)"
echo ""

# ── Warn about download size ─────────────────────────────────────────────
echo -e "${YELLOW}${BOLD}⚠  HEADS UP:${RESET}"
echo -e "${YELLOW}   This build will download:${RESET}"
echo -e "${YELLOW}   • Python packages (optimum-intel, openvino, diffusers, etc.)${RESET}"
echo -e "${YELLOW}   • The SDXS-512-0.9 OpenVINO AI model (~500MB+)${RESET}"
echo -e "${YELLOW}   Total download: approximately 1-2 GB${RESET}"
echo -e "${YELLOW}   Build time: 5-15 minutes depending on connection speed${RESET}"
echo ""
read -p "$(echo -e "${CYAN}Continue with build? [Y/n]: ${RESET}")" confirm
confirm=${confirm:-Y}
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Build cancelled."
    exit 0
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}  Building Docker image: ${IMAGE_NAME}${RESET}"
echo -e "${DIM}  You'll see real-time progress below...${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Build with plain progress so user sees pip install progress bars
# and model download output in real time
DOCKER_BUILDKIT=1 docker build \
    --progress=plain \
    -t "$IMAGE_NAME" \
    .

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  ✓  Build complete!${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# ── Stop and remove any existing container ────────────────────────────
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}  Removing existing container '${CONTAINER_NAME}'...${RESET}"
    docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1
fi

# ── Run the container ─────────────────────────────────────────────────
echo -e "${BOLD}  Starting container '${CONTAINER_NAME}' on port ${PORT}...${RESET}"
docker run -d \
    -p "${PORT}:${PORT}" \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    "$IMAGE_NAME"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  ✓  Container is running!${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${BOLD}Open in your browser:${RESET}"
echo ""
echo -e "  ${CYAN}http://localhost:${PORT}${RESET}"
echo ""
echo -e "  ${DIM}(The model takes ~10-20 seconds to load on first startup.)${RESET}"
echo -e "  ${DIM}The status indicator in the UI will turn cyan when ready.${RESET}"
echo ""
echo -e "  ${BOLD}Lifecycle scripts:${RESET}"
echo -e "  ${DIM}Stop:    ${RESET}./stop_snapshot.sh"
echo -e "  ${DIM}Delete:  ${RESET}./delete_snapshot.sh"
echo -e "  ${DIM}Logs:    ${RESET}docker logs -f ${CONTAINER_NAME}"
echo ""
