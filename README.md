# Snapshot-UI — Text-to-Image Generator

A self-contained Docker application that runs the **SDXS-512-0.9 OpenVINO** text-to-image model with a sleek dark-themed Chat UI.

> **Model:** [rupeshs/sdxs-512-0.9-openvino](https://huggingface.co/rupeshs/sdxs-512-0.9-openvino)
> **Inference:** Single-step generation on CPU via Intel OpenVINO
> **Resolution:** 512×512

![Snapshot-UI Screenshot](https://img.shields.io/badge/theme-dark%20%2B%20cyan-00e5ff?style=for-the-badge)

---

## Prerequisites

- **Docker** installed and running — [Get Docker](https://docs.docker.com/get-docker/)
- ~2 GB of disk space (for model + dependencies)
- Internet connection (for initial build only)

---

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/Snapshot-UI-LLM-Chat.git
cd Snapshot-UI-LLM-Chat
```

### 2. Build the Docker image

```bash
chmod +x setup.sh
./setup.sh
```

> ⚠️ The build downloads the AI model (~500MB+) and Python packages.
> This takes **5–15 minutes** depending on your connection.

### 3. Run the container

```bash
docker run -d -p 9999:9999 --name snapshot-ui snapshot-ui
```

### 4. Open the UI

Navigate to **[http://localhost:9999](http://localhost:9999)** in your browser.

Wait for the status indicator to show **"Model Ready"** (takes ~10–20 seconds on first start), then type a prompt like `A cute cat` and hit Generate!

---

## Usage

1. Type a description in the prompt field (e.g., *"A sunset over mountains"*)
2. Press **Enter** or click the **→** button
3. Wait for the image to generate
4. Click **Download PNG** to save the image

---

## Container Management

| Action  | Command                         |
| ------- | ------------------------------- |
| Start   | `docker start snapshot-ui`      |
| Stop    | `docker stop snapshot-ui`       |
| Logs    | `docker logs -f snapshot-ui`    |
| Remove  | `docker rm -f snapshot-ui`      |
| Rebuild | `./setup.sh`                    |

---

## Architecture

```
Single Docker Container (port 9999)
├── FastAPI Backend
│   ├── GET  /         → Chat UI
│   ├── POST /generate → Image generation
│   └── GET  /health   → Health check
├── OpenVINO Runtime (CPU)
└── SDXS-512-0.9 Model (pre-baked)
```

---

## Credits

- **Model:** [SDXS-512-0.9](https://huggingface.co/IDKiro/sdxs-512-0.9) by IDKiro, OpenVINO conversion by [rupeshs](https://huggingface.co/rupeshs)
- **Runtime:** [Intel OpenVINO](https://docs.openvino.ai/) + [Optimum Intel](https://huggingface.co/docs/optimum/intel/index)
# Snapshot-UI-Text-To-Image-LLM-Docker
