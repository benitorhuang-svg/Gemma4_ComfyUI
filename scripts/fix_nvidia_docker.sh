#!/bin/bash
set -e

echo "🚀 正在修復 NVIDIA Docker 運行環境..."

# 1. 檢查是否為 Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "❌ 此腳本僅適用於 Linux 系統。"
    exit 1
fi

# 2. 安裝 NVIDIA Container Toolkit (如果缺失)
if ! command -v nvidia-ctk &> /dev/null; then
    echo "📦 正在安裝 NVIDIA Container Toolkit..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
else
    echo "✅ NVIDIA Container Toolkit 已安裝。"
fi

# 3. 配置 Docker 運行時
echo "⚙️ 正在配置 Docker NVIDIA 運行時..."
sudo nvidia-ctk runtime configure --runtime=docker
echo "🔄 正在重啟 Docker 服務..."
sudo systemctl restart docker

# 4. 驗證
echo "🔍 驗證 Docker GPU 存取能力..."
if sudo docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    echo "✅ 恭喜！Docker 現在可以成功存取 GPU。"
else
    echo "⚠️ 驗證失敗，但配置已更新。請嘗試執行 'make start' 後觀察。"
fi

echo "🚀 修復完畢。現在請執行: make start"
