#!/usr/bin/env bash
set -euo pipefail

# Define model paths
MODELS_DIR="/workspace/models/checkpoints"
VAE_DIR="/workspace/models/vae"
LORA_DIR="/workspace/models/loras"
UPSCALER_DIR="/workspace/models/upscale_models"
CONTROLNET_DIR="/workspace/models/controlnet"

mkdir -p "$MODELS_DIR" "$VAE_DIR" "$LORA_DIR" "$UPSCALER_DIR" "$CONTROLNET_DIR"

echo "=== 🚀 高速模型下載器 (aria2c) ==="

# Download function to reduce redundancy
download_model() {
    local url=$1
    local dir=$2
    local filename=$3
    if [ ! -f "$dir/$filename" ]; then
        echo "[+] Downloading $filename..."
        aria2c -x 16 -s 16 -k 1M -c --summary-interval=10 "$url" -d "$dir" -o "$filename"
    else
        echo "[*] $filename already exists, skipping."
    fi
}

# 1. SDXL Checkpoint: Juggernaut XL (High quality base)
download_model "https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors" "$MODELS_DIR" "Juggernaut-XL_v9.safetensors"

# 2. SD 1.5 Checkpoint: DreamShaper 8
download_model "https://huggingface.co/Lykon/DreamShaper/resolve/main/DreamShaper_8_pruned.safetensors" "$MODELS_DIR" "DreamShaper_8_pruned.safetensors"

# 3. Standard VAE
download_model "https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors" "$VAE_DIR" "vae-ft-mse-840000-ema-pruned.safetensors"

# 4. Upscaler (RealESRGAN_x4plus)
download_model "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth" "$UPSCALER_DIR" "RealESRGAN_x4plus.pth"

# 5. Gemma 4 related (if needed via direct download, but usually handled by Ollama)
# echo "[INFO] Gemma 4 models are managed by Ollama. Run 'make gemma4' to pull."

echo "=== ✨ 所有模型已檢查/下載完成！ ==="
