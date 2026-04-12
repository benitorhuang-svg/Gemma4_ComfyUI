#!/usr/bin/env bash
set -euo pipefail

echo "=== 🌐 Tailscale 零信任網路部署輔助工具 ==="
echo "此腳本將協助您在宿主機 (Host) 安裝 Tailscale，讓您能從全球任何地方安全存取 AI 工作站。"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "⚠️ 請使用 sudo 權限執行此腳本: sudo bash scripts/setup_tailscale.sh"
  exit 1
fi

if command -v tailscale &> /dev/null; then
    echo "✅ Tailscale 已安裝。"
else
    echo "📥 正在安裝 Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
fi

echo "🚀 啟動 Tailscale 服務..."
systemctl enable --now tailscaled

echo "🔗 請執行以下指令登入您的 Tailscale 帳號並將此機器加入您的私有網路:"
echo "  sudo tailscale up"

echo "=== ✅ 完成後，您可以隨時隨地透過 Tailscale 的 IP 存取 ComfyUI 與 WebUI！ ==="
