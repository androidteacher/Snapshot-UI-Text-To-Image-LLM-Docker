# Snapshot-UI-LLM-Chat

![Snapshot-UI Application](screenshot/application.png)

A self-contained Docker application that runs a **text-to-image AI model** with a sleek, dark-themed web UI. Type a prompt — get an image back instantly in your browser. No cloud, no API keys — everything runs locally on your machine.

---

## System Requirements

> **Minimum: 8 GB RAM | Recommended: 16 GB RAM or more**

This app runs an AI image generation model **entirely on your CPU** inside Docker. Because the model is loaded fully into memory, your machine needs enough RAM to hold it alongside the operating system and Docker overhead.

- With **8 GB**, generation will work, but your system may feel sluggish during use and build times will be longer.
- With **16 GB or more**, the model loads comfortably, generation is smoother, and the rest of your system stays responsive.
- A **virtual machine** is fine — just make sure to allocate at least **8 GB of RAM** to the VM in your hypervisor settings (VirtualBox, VMware, etc.).

---

## Installing Docker (Ubuntu / Kali)

If you don't already have Docker installed, run the following:

```bash
# Update packages and install prerequisites
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine and Docker Compose
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Allow your user to run Docker without sudo (log out and back in after this)
sudo usermod -aG docker $USER
```

> **Kali users:** Replace `ubuntu` with `debian` in the repository URL, or simply use `sudo apt install docker.io docker-compose` for a quick install.

Verify the install:

```bash
docker --version
docker compose version
```

---

## The AI Model: What Is It and Where Does It Come From?

This app uses **SDXS-512-0.9**, an ultra-fast single-step text-to-image diffusion model.

- **Original model:** [IDKiro/sdxs-512-0.9](https://huggingface.co/IDKiro/sdxs-512-0.9) on Hugging Face
- **Runtime-optimized version:** [rupeshs/sdxs-512-0.9-openvino](https://huggingface.co/rupeshs/sdxs-512-0.9-openvino) — converted to Intel **OpenVINO** format for efficient CPU inference

When you run `./setup.sh` to build the Docker image, the model (~500 MB) is **automatically downloaded from Hugging Face** during the build process and baked directly into the Docker image. This means:

- No internet connection is needed after the build
- The container starts quickly (model is already on disk)
- Generation runs fully **offline** at runtime

---

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/Snapshot-UI-LLM-Chat.git
cd Snapshot-UI-LLM-Chat
```

### 2. Build the image

```bash
chmod +x setup.sh
./setup.sh
```

> ⚠️ This downloads ~1–2 GB of data (Python packages + the AI model). Expect **5–15 minutes** on the first build. Subsequent builds use Docker's cache and are much faster.

### 3. Start the container

```bash
docker run -d -p 9999:9999 --name snapshot-ui snapshot-ui
```

### 4. Open the UI and start generating!

Open your browser and navigate to:

```
http://localhost:9999
```

Wait a few seconds for the status indicator to show **"Model Ready"**, then type any prompt and hit **Enter** (or click →).

**Example prompts to try:**
- `A cute cat sitting on a windowsill`
- `A sunset over misty mountains`
- `A cyberpunk city at night with neon lights`
- `A watercolor painting of a lighthouse`

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

## Credits

- **Model:** [SDXS-512-0.9](https://huggingface.co/IDKiro/sdxs-512-0.9) by IDKiro, OpenVINO conversion by [rupeshs](https://huggingface.co/rupeshs/sdxs-512-0.9-openvino)
- **Runtime:** [Intel OpenVINO](https://docs.openvino.ai/) + [Optimum Intel](https://huggingface.co/docs/optimum/intel/index)
- **Backend:** [FastAPI](https://fastapi.tiangolo.com/) + [Uvicorn](https://www.uvicorn.org/)
