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
echo -e "  ${BOLD}To start the container:${RESET}"
echo ""
echo -e "  ${CYAN}docker run -d -p ${PORT}:${PORT} --name ${CONTAINER_NAME} ${IMAGE_NAME}${RESET}"
echo ""
echo -e "  ${BOLD}Then open in your browser:${RESET}"
echo ""
echo -e "  ${CYAN}http://localhost:${PORT}${RESET}"
echo ""
echo -e "  ${DIM}(The model takes ~10-20 seconds to load on first startup.)${RESET}"
echo -e "  ${DIM}The status indicator in the UI will turn cyan when ready.${RESET}"
echo ""
echo -e "  ${BOLD}Other commands:${RESET}"
echo -e "  ${DIM}Stop:    ${RESET}docker stop ${CONTAINER_NAME}"
echo -e "  ${DIM}Start:   ${RESET}docker start ${CONTAINER_NAME}"
echo -e "  ${DIM}Logs:    ${RESET}docker logs -f ${CONTAINER_NAME}"
echo -e "  ${DIM}Remove:  ${RESET}docker rm -f ${CONTAINER_NAME}"
echo ""
