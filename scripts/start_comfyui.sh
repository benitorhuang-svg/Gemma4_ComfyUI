#!/usr/bin/env bash
set -euo pipefail

cd /workspace

# Ensure models and ComfyUI exist
mkdir -p /workspace/models/checkpoints

if [ ! -d "ComfyUI" ]; then
  echo "ComfyUI not found in container; repository should be present at /workspace/ComfyUI"
fi

echo "Starting ComfyUI (listening on 8188)..."
cd ComfyUI
exec python main.py --dont-print-server
