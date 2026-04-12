#!/usr/bin/env bash
set -euo pipefail

MODELS_DIR="/workspace/models/checkpoints"
mkdir -p "$MODELS_DIR"

if [ ! -f "$MODELS_DIR/DreamShaper_8_pruned.safetensors" ]; then
  echo "Downloading DreamShaper_8_pruned.safetensors..."
  wget -c https://huggingface.co/Lykon/DreamShaper/resolve/main/DreamShaper_8_pruned.safetensors -O "$MODELS_DIR/DreamShaper_8_pruned.safetensors"
else
  echo "DreamShaper model already present."
fi
