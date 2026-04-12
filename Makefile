# Gemma 4 + ComfyUI Project Management

.PHONY: start stop restart logs clean shell gemma4 help sync

# Default action
all: help

help:
	@echo "可用指令:"
	@echo "  make start            - 啟動所有服務 (背景執行)"
	@echo "  make stop             - 停止所有服務"
	@echo "  make restart          - 重啟所有服務"
	@echo "  make logs             - 查看所有服務日誌 (監控下載進度)"
	@echo "  make shell            - 進入 ComfyUI 容器終端"
	@echo "  make gemma4           - 啟動 Gemma 4 交互對話 (E2B)"
	@echo "  make download-models  - 執行模型下載腳本"
	@echo "  make sync             - 同步本地 uv 環境"

start:
	docker compose up --build -d

stop:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

shell:
	docker exec -it comfyui bash

gemma4:
	docker exec -it ollama ollama run gemma4:e2b

download-models:
	docker compose run --rm comfyui /workspace/scripts/download_models.sh

sync:
	uv sync
