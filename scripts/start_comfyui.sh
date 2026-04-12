#!/usr/bin/env bash
set -euo pipefail

cd /workspace

# --- 1. 確保基礎目錄結構 ---
echo "⚙️ 正在初始化工作空間..."
mkdir -p /workspace/models/checkpoints /workspace/models/vae /workspace/models/loras /workspace/models/upscale_models /workspace/models/controlnet
mkdir -p /workspace/ComfyUI/custom_nodes /workspace/ComfyUI/output /workspace/ComfyUI/input /workspace/workflows

# --- 2. 背景模型檢查 (Ollama) ---
# 透過環境變量 GEMMA_MODEL 決定要下載哪個版本
TARGET_MODEL=${GEMMA_MODEL:-gemma4:e2b}
if curl -s --connect-timeout 2 http://ollama:11434/api/tags > /dev/null; then
  echo "🤖 檢查 Ollama 模型狀態..."
  if ! curl -s http://ollama:11434/api/tags | grep -q "${TARGET_MODEL}"; then
    echo "⬇️ 偵測到模型 ${TARGET_MODEL} 缺失，正在背景啟動下載任務..."
    curl -X POST http://ollama:11434/api/pull -d "{\"name\": \"${TARGET_MODEL}\"}" > /dev/null &
  fi
else
  echo "⚠️ 警告: 無法連線至 Ollama 服務，跳過模型檢查。"
fi

# --- 3. 自動修復 & 安裝自定義節點依賴 ---
echo "🧩 掃描並確保核心插件存在..."
NODES_DIR="/workspace/ComfyUI/custom_nodes"

# 自動克隆 ComfyUI-Manager (必備管理工具)
if [ ! -d "$NODES_DIR/ComfyUI-Manager" ]; then
  echo "📥 安裝 ComfyUI-Manager..."
  git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git "$NODES_DIR/ComfyUI-Manager"
fi

# 自動克隆 ComfyUI-Ollama (聯動 Gemma 4)
if [ ! -d "$NODES_DIR/ComfyUI-Ollama" ]; then
  echo "📥 安裝 ComfyUI-Ollama..."
  git clone --depth 1 https://github.com/vrtmrz/ComfyUI-Ollama.git "$NODES_DIR/ComfyUI-Ollama"
fi

if [ -d "$NODES_DIR" ]; then
  find "$NODES_DIR" -maxdepth 2 -name "requirements.txt" | while read -r req; do
    echo "📦 檢查依賴: $req"
    uv pip install --system -r "$req" || echo "⚠️ 警告: $req 安裝失敗，跳過。"
  done
fi

# --- 4. 顯存診斷與自動配置 ---
# 偵測顯存大小 (以 MiB 為單位)
if command -v nvidia-smi &> /dev/null; then
  VRAM_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n 1)
  echo "📟 偵測到 GPU 顯存: ${VRAM_TOTAL} MiB"
  
  COMFY_OPTS="--listen 0.0.0.0 --port 8188 --use-pytorch-cross-attention"
  
  if [ "${VRAM_TOTAL}" -lt 8000 ]; then
    echo "💡 顯存低於 8GB，啟用 --lowvram 模式"
    COMFY_OPTS="${COMFY_OPTS} --lowvram"
  elif [ "${VRAM_TOTAL}" -lt 14000 ]; then
    echo "💡 顯存介於 8GB-14GB，啟用 --normalvram 模式"
    COMFY_OPTS="${COMFY_OPTS} --normalvram"
  else
    echo "🚀 顯存充足 (16GB+)，啟用 --highvram 模式"
    COMFY_OPTS="${COMFY_OPTS} --highvram"
  fi
else
  echo "⚠️ 偵測不到 NVIDIA GPU，將使用 CPU/默認模式啟動"
  COMFY_OPTS="--listen 0.0.0.0 --port 8188 --cpu"
fi

# --- 5. 啟動 ComfyUI ---
if [ ! -d "ComfyUI" ]; then
  echo "❌ 錯誤: 找不到 ComfyUI 目錄。"
  exit 1
fi

echo "🚀 啟動 ComfyUI..."
cd ComfyUI
exec python main.py ${COMFY_OPTS} "$@"
