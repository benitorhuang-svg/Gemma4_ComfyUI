# 🚀 Gemma 4 + ComfyUI + Open WebUI：全方位 AI 創作工作站 (v2.5)

[![Gemma 4](https://img.shields.io/badge/Gemma_4-Uncensored_&_Thinking-red?style=for-the-badge&logo=googlecloud)](https://blog.google/)
[![Open WebUI](https://img.shields.io/badge/Interface-Open_WebUI-blue?style=for-the-badge)](https://openwebui.com/)
[![ComfyUI](https://img.shields.io/badge/Engine-ComfyUI-green?style=for-the-badge)](https://github.com/comfyanonymous/ComfyUI)

本專案是一個深度優化的「極致生產力」工作站，結合了 **Google Gemma 4** 的深度推理能力、**Open WebUI** 的優雅對話介面，以及 **ComfyUI** 的專業影像生成能力。透過三位一體的架構，實現「對話即創作」的極速體驗。

---

## 🏗️ 核心架構：AI 三位一體 (The Triple Threat)

| 組件 | 角色 | 功用 | 訪問端口 |
| :--- | :--- | :--- | :--- |
| **Gemma 4** | **大腦 (The Brain)** | 負責思考、去審查對話、擴充生圖提示詞 (Prompt)。 | Ollama 底層 |
| **ComfyUI** | **畫筆 (The Pen)** | 專業節點式影像生成，執行 Stable Diffusion 創作。 | `:8188` |
| **Open WebUI** | **介面 (The Face)** | 像 ChatGPT 一樣親切的對話前台，用於日常交流。 | `:8080` |

---

## ✨ 深度優化黑科技 (Optimization Features)

### 1. 🧠 思考型模型支援 (Thinking Model Support)
*   **預設整合**：完美支援 `tripolskypetr/gemma4-uncensored-aggressive`。
*   **內部推理**：模型在輸出前會進行 `<thinking>` 邏輯推演，產出更高質量的藝術構思。
*   **0/465 Refusals**：採用去審查版本，釋放 AI 在創意寫作與藝術提示詞上的極限。

### 2. 📟 智能顯存調度 (VRAM Smart-Tune)
*   **自動偵測**：啟動時自動掃描 GPU，動態切換 `--lowvram` 或 `--highvram` 模式。
*   **TCMalloc 注入**：解決長時運行內存洩漏，生圖效率穩定不墜。

### 3. ⚡ 自動化運維 (Automation & DevOps)
*   **並行更新**：`make update-nodes` 使用 4 進程並發，極速同步插件。
*   **智能診斷**：`python main.py` 提供環境自檢、目錄容量報告與自癒建議。
*   **自動依賴安裝**：每次啟動自動掃描並安裝自定義節點的 `requirements.txt`。

---

## 🛠️ 快速開始 (Quick Start)

### 1. 啟動環境
```bash
cp .env.example .env  # 填寫 NGROK_TOKEN
make start           # 啟動所有容器 (Ollama, WebUI, ComfyUI)
```

### 2. 部署模型
```bash
make download-models # 下載 Juggernaut-XL 與 SDXL 基礎權重
# 系統將會自動背景拉取 Gemma 4 去審查模型
```

### 3. 開始創作
*   **對話聊天**：訪問 `http://localhost:8080` (Open WebUI)。
*   **藝術生圖**：訪問 `http://localhost:8188` (ComfyUI)，可拖入 `data/workflows/` 中的範本。

---

## 🏗️ 優化指令集 (Command List)

| 指令 | 說明 |
| :--- | :--- |
| `make status` | 實時查看所有服務健康度與資源佔用 (CPU/MEM) |
| `make monitor` | 使用 `gpustat` 提供專業的 GPU 顯存與負載報表 |
| `make update-nodes` | [極速] 並行更新所有 ComfyUI 自訂節點 |
| `make backup` | [安全] 帶有日期與模型版本的智能備份 |
| `make prune` | [清潔] 自動清理舊輸出、舊備份與 Docker 緩存 |

---

## 📜 聲明
本專案為開發者社群分享之研究成果。Gemma 4 模型權利歸 Google 所有，使用請遵守相關社群規範。
