"""
Download and cache the SDXS-512-0.9 OpenVINO model during Docker build.
This script is run once during `docker build` so the model is pre-baked
into the image and doesn't need to be downloaded at runtime.
"""

import sys

def main():
    print("=" * 60)
    print("  Downloading SDXS-512-0.9 OpenVINO Model")
    print("  This may take several minutes depending on your connection...")
    print("=" * 60)
    sys.stdout.flush()

    from optimum.intel.openvino.modeling_diffusion import OVStableDiffusionPipeline

    print("\n[1/2] Downloading model from HuggingFace...")
    sys.stdout.flush()

    pipeline = OVStableDiffusionPipeline.from_pretrained(
        "rupeshs/sdxs-512-0.9-openvino",
        ov_config={"CACHE_DIR": ""},
    )

    print("[2/2] Model downloaded and cached successfully!")
    print("=" * 60)
    print("  Model is ready for inference.")
    print("=" * 60)
    sys.stdout.flush()

    # Clean up to free memory
    del pipeline

if __name__ == "__main__":
    main()
