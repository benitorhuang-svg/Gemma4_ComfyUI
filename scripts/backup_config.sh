#!/usr/bin/env bash
set -euo pipefail

# 載入 .env 獲取模型資訊
if [ -f .env ]; then
  source .env
fi

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M")
MODEL_TAG=${GEMMA_MODEL:-gemma4_e2b}
BACKUP_NAME="gemma4_config_${MODEL_TAG}_${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "=== 💾 正在執行深度備份 (${MODEL_TAG}) ==="

# 排除不需要的文件，保持備份精簡
# 排除模型、日誌、臨時緩存
tar --exclude='data/models/*' \
    --exclude='data/ollama/*' \
    --exclude='data/comfyui/output/*' \
    --exclude='data/comfyui/input/*' \
    --exclude='data/comfyui/custom_nodes/*/node_modules' \
    --exclude='data/comfyui/custom_nodes/*/.git' \
    --exclude='__pycache__' \
    --exclude='*.log' \
    -czf "$BACKUP_DIR/$BACKUP_NAME" \
    .env \
    pyproject.toml \
    uv.lock \
    docker-compose.yml \
    Makefile \
    data/comfyui/custom_nodes \
    data/workflows \
    data/open-webui \
    scripts/

# 驗證備份是否成功
if [ -f "$BACKUP_DIR/$BACKUP_NAME" ]; then
  SIZE=$(du -sh "$BACKUP_DIR/$BACKUP_NAME" | cut -f1)
  echo "=== ✅ 備份成功！ ==="
  echo "📁 檔案: $BACKUP_DIR/$BACKUP_NAME"
  echo "📦 大小: $SIZE"
  echo "💡 提示: 備份已排除大型模型權重，恢復後請執行 'make download-models'。"
else
  echo "❌ 錯誤: 備份失敗！"
  exit 1
fi
