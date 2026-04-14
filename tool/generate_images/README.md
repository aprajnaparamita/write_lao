# Lao Character Illustration Generator

Generate cute acrophonical illustrations for each Lao consonant using FLUX.1-schnell on a Tesla P40 (24GB VRAM).

## Hardware Requirements

- GPU: 1x Tesla P40 (24GB VRAM) or equivalent
- RAM: 32GB+ system memory recommended
- Disk: ~15GB for model weights

## Setup (PyTorch + FLUX.1)

```bash
# 1. Create environment
conda create -n lao-art python=3.11 -y
conda activate lao-art

# 2. Install PyTorch (CUDA 12.x — adjust for your CUDA version)
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

# 3. Install diffusers and dependencies
pip install diffusers transformers accelerate safetensors sentencepiece protobuf pillow

# 4. Verify GPU
python -c "import torch; print(f'GPU: {torch.cuda.get_device_name(0)}, VRAM: {torch.cuda.get_device_properties(0).total_mem / 1e9:.1f}GB')"
```

## Generate

```bash
# Generate all images (skips existing)
python generate.py

# Regenerate all
python generate.py --force

# Generate a single character for testing
python generate.py --only U+0E81

# Adjust resolution (default 512x512)
python generate.py --size 768
```

## Output

Images are saved to `../../assets/images/acrophonical/` as `{codepoint}.png`:
- `U+0E81.png` — chicken (ໄກ່)
- `U+0E82.png` — egg (ໄຂ່)
- etc.

## Notes

- Tesla P40 doesn't support bf16 — the script uses fp16 with float32 fallback for VAE
- FLUX.1-schnell is Apache 2.0 licensed and free for commercial use
- First run downloads ~12GB of model weights (cached in ~/.cache/huggingface)
- Generation takes ~15-25 seconds per image on P40
- If you run out of VRAM, add `--low-vram` flag for sequential CPU offloading
