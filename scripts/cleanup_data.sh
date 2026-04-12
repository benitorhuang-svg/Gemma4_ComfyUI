#!/usr/bin/env bash
set -euo pipefail

echo "=== 🧹 Gemma4 + ComfyUI 磁碟清理工具 ==="

# 1. 清理舊輸出 (預設保留 7 天)
OUTPUT_DIR="./data/comfyui/output"
if [ -d "$OUTPUT_DIR" ]; then
    echo "[+] 正在清理 7 天前的生成結果..."
    find "$OUTPUT_DIR" -type f -mtime +7 -delete
fi

# 2. 清理舊備份 (預設保留 5 個最新備份)
BACKUP_DIR="./backups"
if [ -d "$BACKUP_DIR" ]; then
    echo "[+] 正在清理舊備份，僅保留最新 5 個..."
    ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tail -n +6 | xargs rm -f || true
fi

# 3. 清理 Docker 系統
echo "[+] 正在清理 Docker 緩存..."
docker system prune -f --filter "label=com.docker.compose.project=gemma4-comfyui"

echo "=== ✅ 清理完成！ ==="
