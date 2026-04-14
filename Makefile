# Gemma 4 + ComfyUI Project Management
include .env
export $(shell sed 's/=.*//' .env)

.PHONY: start stop restart restart-comfy restart-ollama logs logs-comfy clean shell gemma4 help sync download-models update-nodes monitor share backup lint format prune status doctor check dashboard

# ... (other code) ...

doctor:
	@echo "🩺 正在執行全方位系統診斷..."
	@docker --version || echo "❌ Docker 缺失"
	@nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv || echo "❌ GPU 驅動或容器調度異常"
	@docker compose config > /dev/null || echo "❌ Docker Compose 配置錯誤"
	@test -f .env || echo "⚠️ .env 缺失，建議從 deploy/.env.example 複製"
	@echo "🌐 檢查服務連通性..."
	@curl -s http://localhost:11434 > /dev/null && echo "✅ Ollama 端口連通" || echo "⚠️ Ollama 尚未啟動或端口未開放"
	@curl -s http://localhost:5678 > /dev/null && echo "✅ n8n 端口連通" || echo "⚠️ n8n 尚未啟動"
	@df -h . | awk 'NR==2 {if ($$4 < 10) print "⚠️ 磁碟剩餘空間不足 10GB (" $$4 " 剩餘)"}'
	@echo "✅ 診斷完成。如有問題，請嘗試執行 'make prune'。"

check:
	@echo "🔍 執行本地代碼品質檢查..."
	uv run ruff check .
	uv run ruff format --check .
	@docker compose config -q && echo "✅ Docker Compose 配置正確"

build-brain:
	@echo "🧠 正在將 Gemma 4 轉化為 ComfyUI 專家模式..."
	@docker exec -it ollama ollama create gemma4-comfy-expert -f /root/.ollama/Gemma4_Comfy_Expert.Modelfile
	@echo "✅ 成功！現在可以使用 'gemma4-comfy-expert' 模型了。"

sync-modelfile:
	@docker cp scripts/Gemma4_Comfy_Expert.Modelfile ollama:/root/.ollama/

help:
	@echo "🚀 Gemma 4 + ComfyUI 系統管理指令:"
	@echo "  make start            - 啟動所有服務 (背景執行)"
	@echo "  make cpu-start        - 以 CPU 模式啟動服務 (無需 GPU 驅動)"
	@echo "  make stop             - 停止所有服務"
	@echo "  make status           - 查看服務健康狀態與資源佔用"
	@echo "  make restart          - 重啟所有服務"
	@echo "  make logs             - 查看所有服務日誌 (Tail)"
	@echo "  make shell            - 進入 ComfyUI 容器終端"
	@echo "  make gemma4           - 啟動 Gemma 4 交互對話 (Ollama)"
	@echo "  make download-models  - [加速] 下載常用模型 (Aria2)"
	@echo "  make update-nodes     - 一鍵更新所有 ComfyUI 插件 (Git Pull)"
	@echo "  make backup           - 備份設定檔與工作流 (不含模型)"
	@echo "  make monitor          - 即時監控 GPU 顯存與負載"
	@echo "  make sync             - 同步本地 uv 環境"
	@echo "  make share            - 使用 ngrok 開放外部存取 (含安全鎖)"
	@echo "  make prune            - 深度清理 Docker 殘留數據"

start:
	docker compose up --build -d
	@echo "✅ 服務已啟動！"
	@echo "🔗 ComfyUI: http://localhost:8188"
	@echo "🔗 WebUI:   http://localhost:8080"
	@echo "\n💡 如果 http://localhost 無法開啟，請嘗試使用次要位址:"
	@echo "   http://127.0.0.1:8188"
	@echo "   http://$(shell ip addr show eth0 | grep 'inet ' | awk '{print $$2}' | cut -d/ -f1):8188"

stop:
	docker compose down

status:
	@echo "=== 📊 容器狀態 ==="
	@docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}\t{{.Ports}}"
	@echo "\n=== 🔋 資源佔用 ==="
	@docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

restart:
	docker compose restart

restart-comfy:
	docker compose restart comfyui

logs:
	docker compose logs -f --tail 100

shell:
	docker exec -it comfyui bash

gemma4:
	docker exec -it ollama ollama run ${GEMMA_MODEL:-gemma4:e2b}

download-models:
	docker exec -it comfyui bash /workspace/scripts/download_models.sh

update-nodes:
	docker exec -it comfyui bash /workspace/scripts/update_custom_nodes.sh

monitor:
	@if command -v gpustat &> /dev/null; then \
		watch --color -n 1 gpustat --color --g -u -i; \
	else \
		watch -n 1 nvidia-smi; \
	fi

backup:
	bash scripts/backup_config.sh

lint:
	uv run ruff check src scripts experiments
	@echo "✅ 代碼品質檢查完畢。"

format:
	uv run ruff format src scripts experiments
	@echo "✅ 代碼格式化完成。"

dashboard:
	@echo "📟 正在啟動運維儀表板..."
	@uv run python src/dashboard.py

sync:
	uv sync

share:
	docker exec -it comfyui python /workspace/scripts/ngrok_share.py

flush:
	@echo "🧹 正在清理系統與殘留的 VRAM..."
	@sudo nvidia-smi --gpu-reset || echo "⚠️ 無法完全重置，嘗試清理殘留進程..."
	@sudo fuser -v /dev/nvidia* | awk '{print $$2}' | xargs -r kill -9 || true
	@echo "✅ 顯存與系統資源清理完畢。"

prune:
	@echo "🧹 正在深度清理 Docker 殘留數據..."
	docker compose down -v --remove-orphans
	docker system prune -f
	@echo "✅ 清理完成。"

cpu-start:
	@echo "⚠️ 正在以 CPU 模式啟動服務 (性能可能較低)..."
	docker compose -f docker-compose.yml -f docker/docker-compose.cpu.yml up --build -d
	@echo "✅ 服務已在 CPU 模式下啟動！"

api-server:
	@echo "📱 正在啟動行動端 API 閘道器..."
	@uv run uvicorn experiments.mobile_api:app --host 0.0.0.0 --port 8000
