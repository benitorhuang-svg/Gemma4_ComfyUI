#!/usr/bin/env bash
set -euo pipefail

NODES_DIR="/workspace/ComfyUI/custom_nodes"

echo "=== 🔄 正在「並行」更新所有 ComfyUI 自訂節點 ==="

if [ ! -d "$NODES_DIR" ]; then
  echo "❌ 錯誤: 找不到 custom_nodes 目錄 ($NODES_DIR)"
  exit 1
fi

cd "$NODES_DIR"

# 限制並行數量，避免網絡擁塞或磁碟 I/O 瓶頸
MAX_JOBS=4
count=0

for dir in */; do
  if [ -d "$dir/.git" ]; then
    echo "⬇️ 啟動更新: $dir"
    (
      if cd "$dir" && git pull --quiet; then
        echo "✅ 完成: $dir"
      else
        echo "❌ 失敗: $dir"
      fi
    ) &
    
    ((count++))
    if (( count % MAX_JOBS == 0 )); then
      wait
    fi
  else
    echo "⏭️ 跳過 (非 Git): $dir"
  fi
done

wait
echo "=== ✨ 所有節點更新完成！請重啟服務以套用變更。 ==="
