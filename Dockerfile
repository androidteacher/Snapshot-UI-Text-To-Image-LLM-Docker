# ==========================================================================
#  Snapshot-UI: Text-to-Image Docker Container
#  Single container running SDXS-512-0.9 OpenVINO + FastAPI Chat UI
# ==========================================================================

FROM python:3.10-slim

# Prevent Python from buffering stdout/stderr (gives real-time build output)
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# System dependencies for image processing (Pillow, OpenVINO)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libgl1 \
        libglib2.0-0 \
        libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies first (Docker layer caching)
COPY requirements.txt .
RUN echo "========================================" && \
    echo "  Installing Python dependencies...    " && \
    echo "========================================" && \
    pip install --no-cache-dir --progress-bar on -r requirements.txt && \
    echo "  Python dependencies installed!" && \
    echo "========================================"

# Copy application code
COPY app/ /app/

# Pre-download the model during build (baked into the image)
RUN echo "========================================" && \
    echo "  Downloading AI Model (~500MB+)       " && \
    echo "  This will take a few minutes...      " && \
    echo "========================================" && \
    python download_model.py

EXPOSE 9999

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:9999/health')" || exit 1

# Run the server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "9999"]
