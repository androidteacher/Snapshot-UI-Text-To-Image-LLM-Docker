"""
Snapshot-UI: Text-to-Image API Backend
FastAPI server that serves the Chat UI and handles image generation
using the SDXS-512-0.9 OpenVINO model.
"""

import base64
import io
import time
import logging

from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("snapshot-ui")

# ---------------------------------------------------------------------------
# App setup
# ---------------------------------------------------------------------------
app = FastAPI(title="Snapshot-UI", description="Text-to-Image Generator")

pipeline = None  # loaded on startup


class GenerateRequest(BaseModel):
    prompt: str


# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------
@app.on_event("startup")
async def load_model():
    """Load the OpenVINO pipeline once at startup."""
    global pipeline
    logger.info("Loading SDXS-512-0.9 OpenVINO model...")
    start = time.time()

    from optimum.intel.openvino.modeling_diffusion import OVStableDiffusionPipeline

    pipeline = OVStableDiffusionPipeline.from_pretrained(
        "rupeshs/sdxs-512-0.9-openvino",
        ov_config={"CACHE_DIR": ""},
    )

    elapsed = round(time.time() - start, 1)
    logger.info(f"Model loaded in {elapsed}s")


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------
@app.get("/")
async def serve_ui():
    """Serve the Chat UI."""
    return FileResponse("/app/static/index.html")


@app.get("/health")
async def health():
    """Health check endpoint."""
    return {"status": "ok", "model_loaded": pipeline is not None}


@app.post("/generate")
async def generate_image(req: GenerateRequest):
    """Generate an image from a text prompt."""
    if pipeline is None:
        raise HTTPException(status_code=503, detail="Model is still loading. Please wait.")

    prompt = req.prompt.strip()
    if not prompt:
        raise HTTPException(status_code=400, detail="Prompt cannot be empty.")

    logger.info(f"Generating image for prompt: '{prompt}'")
    start = time.time()

    try:
        result = pipeline(
            prompt=prompt,
            width=512,
            height=512,
            num_inference_steps=1,
            guidance_scale=1.0,
        )
        image = result.images[0]
    except Exception as e:
        logger.error(f"Generation failed: {e}")
        raise HTTPException(status_code=500, detail=f"Image generation failed: {str(e)}")

    # Convert PIL image to base64 PNG
    buffer = io.BytesIO()
    image.save(buffer, format="PNG")
    buffer.seek(0)
    img_base64 = base64.b64encode(buffer.getvalue()).decode("utf-8")

    elapsed = round(time.time() - start, 2)
    logger.info(f"Image generated in {elapsed}s")

    return JSONResponse({
        "image": img_base64,
        "elapsed": elapsed,
    })


# ---------------------------------------------------------------------------
# Static files (CSS, JS) — mounted AFTER explicit routes so they don't
# shadow /generate, /health, etc.
# ---------------------------------------------------------------------------
app.mount("/static", StaticFiles(directory="/app/static"), name="static")
