#!/usr/bin/env bash
# set -euo pipefail # 保持寬鬆模式，確保在網路波動時仍能嘗試啟動

cd /workspace
export GIT_TERMINAL_PROMPT=0

# --- 1. 確保基礎目錄結構 ---
echo "⚙️ 正在初始化工作空間..."
mkdir -p /workspace/ComfyUI/models/checkpoints /workspace/ComfyUI/models/vae /workspace/ComfyUI/models/loras /workspace/ComfyUI/models/upscale_models /workspace/ComfyUI/models/controlnet
mkdir -p /workspace/ComfyUI/custom_nodes /workspace/ComfyUI/output /workspace/ComfyUI/input /workspace/workflows

# --- 2. 背景模型檢查 (Ollama) ---
TARGET_MODEL=${GEMMA_MODEL:-gemma4:e2b}
if command -v curl &> /dev/null && curl -s --connect-timeout 2 http://ollama:11434/api/tags > /dev/null; then
  echo "🤖 檢查 Ollama 模型狀態..."
  if ! curl -s http://ollama:11434/api/tags | grep -q "${TARGET_MODEL}"; then
    echo "⬇️ 偵測到模型 ${TARGET_MODEL} 缺失，正在背景啟動下載任務..."
    curl -X POST http://ollama:11434/api/pull -d "{\"name\": \"${TARGET_MODEL}\"}" > /dev/null &
  fi
else
  echo "⚠️ 警告: 無法連線至 Ollama 服務，跳過模型檢查。"
fi

# --- 3. 自動安裝核心插件與依賴 ---
export PYTHONPATH="${PYTHONPATH:-}:/workspace/ComfyUI"
echo "🧩 掃描並確保核心插件存在..."
NODES_DIR="/workspace/ComfyUI/custom_nodes"

# 自動克隆 ComfyUI-Manager
if [ ! -d "$NODES_DIR/ComfyUI-Manager" ]; then
  echo "📥 安裝 ComfyUI-Manager..."
  git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git "$NODES_DIR/ComfyUI-Manager" || echo "⚠️ ComfyUI-Manager 下載失敗"
fi

# 自動克隆 ComfyUI-Ollama (聯動 Gemma 4)
if [ ! -d "$NODES_DIR/ComfyUI-Ollama" ]; then
  echo "📥 安裝 ComfyUI-Ollama..."
  git clone --depth 1 https://github.com/vrtmrz/ComfyUI-Ollama.git "$NODES_DIR/ComfyUI-Ollama" || echo "⚠️ ComfyUI-Ollama 下載失敗"
fi

# 自動克隆 ComfyUI-TensorRT (極致生圖加速)
if [ ! -d "$NODES_DIR/ComfyUI-TensorRT" ]; then
  echo "📥 安裝 ComfyUI-TensorRT..."
  git clone --depth 1 https://github.com/comfyanonymous/ComfyUI-TensorRT.git "$NODES_DIR/ComfyUI-TensorRT" || echo "⚠️ ComfyUI-TensorRT 下載失敗"
fi

# 掃描並安裝所有插件的依賴 (這一步最耗時)
if [ -d "$NODES_DIR" ]; then
  echo "📦 正在掃描插件目錄以安裝 Python 依賴，請耐心等候..."
  find "$NODES_DIR" -maxdepth 2 -name "requirements.txt" | while read -r req; do
    echo "⬇️ 處理依賴: $req"
    uv pip install --system --concurrent-downloads 10 --index-url https://mirrors.aliyun.com/pypi/simple/ -r "$req" || echo "⚠️ 警告: $req 安裝失敗，跳過。"
  done
fi

# --- 4. 顯存診斷與自動配置 ---
if command -v nvidia-smi &> /dev/null; then
  VRAM_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n 1)
  echo "📟 偵測到 GPU 顯存: ${VRAM_TOTAL} MiB"
  COMFY_OPTS="--listen 0.0.0.0 --port 8188 --use-pytorch-cross-attention --enable-cors-header '*' --preview-method auto --front-end-version Comfy-Org/ComfyUI_frontend@latest --force-fp16 --preview-method auto"
  if [ "${VRAM_TOTAL}" -lt 8000 ]; then
    COMFY_OPTS="${COMFY_OPTS} --lowvram"
  elif [ "${VRAM_TOTAL}" -lt 14000 ]; then
    COMFY_OPTS="${COMFY_OPTS} --normalvram"
  else
    COMFY_OPTS="${COMFY_OPTS} --highvram"
  fi
else
  echo "⚠️ 偵測不到 NVIDIA GPU，使用 CPU 模式"
  COMFY_OPTS="--listen 0.0.0.0 --port 8188 --cpu"
fi

# --- 5. 啟動 ComfyUI ---
echo "🚀 正在啟動 ComfyUI 主程式..."
cd /workspace/ComfyUI
exec python main.py ${COMFY_OPTS} "$@"
