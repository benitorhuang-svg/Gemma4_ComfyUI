# 🚀 Gemma 4 + ComfyUI + n8n：全方位 AI 自動化創作工作站

[![Gemma 4](https://img.shields.io/badge/Gemma_4-Uncensored_&_Thinking-red?style=for-the-badge&logo=googlecloud)](https://blog.google/)
[![Open WebUI](https://img.shields.io/badge/Interface-Open_WebUI-blue?style=for-the-badge)](https://openwebui.com/)
[![Optimization](https://img.shields.io/badge/VRAM-RTX_2060_Optimized-cyan?style=for-the-badge)](https://www.nvidia.com/)

本專案是一個深度優化的「極致生產力」工作站，專為 **Google Gemma 4** 與 **Stable Diffusion (ComfyUI)** 的協作而設計。透過五輪深度優化，實現了 VRAM 接力調度、TensorRT 加速與全球私有雲連線。

---

## 🏗️ 核心架構：AI 三位一體 (The Triple Threat)

| 組件 | 角色 | 功用 | 訪問端口 |
| :--- | :--- | :--- | :--- |
| **Gemma 4** | **大腦 (The Brain)** | 負責思考、去審查對話、擴充生圖提示詞 (Prompt)。 | Ollama 底層 |
| **ComfyUI** | **畫筆 (The Pen)** | 專業節點式影像生成，支援 TensorRT 加速。 | `:8188` |
| **Open WebUI** | **介面 (The Face)** | 像 ChatGPT 一樣親切的對話前台，用於日常交流。 | `:8080` |
| **n8n** | **脈絡 (The Logic)** | 低代碼自動化工作流，串接 API、定時任務與通知。 | `:5678` |
| **Mobile API** | **閘道 (Gateway)** | 行動端快捷 API，支援 iOS 捷徑語音生圖。 | `:8000` |

---

## 📂 企業級目錄結構 (Project Structure)

專案採用 src-based 佈署架構，確保開發與運作環境的極致純淨：

```text
Gemma4_ComfyUI/
├── src/                # 核心代碼基地 (Dashboard, Logic)
├── tests/              # 品質保證單元測試
├── deploy/             # 部署設定檔 (.env.example)
├── scripts/            # 自動化劇本 (Optimization, Setup)
├── docker/             # Docker 容器環境定義
├── data/               # 本地數據快取 (已設 Git 忽略)
├── Makefile            # 全局系統指揮官
└── README.md           # 專案戰術手冊
```

---

## 💎 Gemma 4 官方精度規格表 (Memory Specs)

根據 [Gemma 官方文檔](https://ai.google.dev/gemma/docs/core?hl=zh-tw)，系統建議針對 VRAM 進行以下精度選擇：

| 參數規格 | BF16 (16 位元) | SFP8 (8 位元) | Q4_0 (4 位元) | 建議顯卡 |
| :--- | :--- | :--- | :--- | :--- |
| **Gemma 4 E2B** | 9.6 GB | 4.6 GB | **3.2 GB** | **RTX 2060 (6GB)** |
| **Gemma 4 E4B** | 15 GB | 7.5 GB | 5 GB | RTX 3060 (12GB) |
| **Gemma 4 31B** | 58.3 GB | 30.4 GB | 17.4 GB | RTX 3090 (24GB) |
| **Gemma 4 26B A4B** | 48 GB | 25 GB | 15.6 GB | Multi-GPU |

> [!TIP]
> **RTX 2060 最佳實踐**：強烈建議使用 **Q4_0 (3.2 GB)** 版本以保留充足顯存給 ComfyUI 生圖引擎。

---

## ✨ 卓越優化黑科技 (Optimization Features)

### 1. 📟 6GB 顯存「接力賽」調度 (RTX 2060 Optimized)
*   **0s Keep-Alive**：專為 6GB 顯卡設計。Gemma 4 生成提示詞後立即釋放 VRAM，將整張顯示卡讓給 ComfyUI 繪圖。
*   **TensorRT 加速**：內建 `ComfyUI-TensorRT` 支援，將生圖速度提升 **50% - 100%**。
*   **TurboQuant (KV Cache)**：底層啟用 `turbo4` 量化技術，將 Gemma 4 的 KV 快取佔用降低 **60%**，大幅提升長對話性能。
*   **CUDA 記憶體優化**：啟用 `expandable_segments`，有效防止顯存碎片化導致的崩潰。

### 2. 🌍 全球私有雲連線 (Zero Trust Network)
*   **Tailscale 整合**：內建 `scripts/setup_tailscale.sh`。無需公網 IP，即可從手機、平板在全球任何地方安全連回您的工作站。

### 3. ⚡ 極速自動化 (Automation & DevOps)
*   **n8n 深度整合**：預裝自動化工作流引擎。支援通過 Webhook 觸發生圖，並自動將成果發送到 Line、Notion 或雲端硬碟。
*   **全域鏡像源**：Apt、Pip、UV 下載皆鎖定高速鏡像站，2.5GB 的 PyTorch 下載不再是噩夢。
*   **自癒啟動引擎**：自動安裝插件依賴，並偵測 VRAM 動態切換 `--lowvram` 模式。
*   **高品質規範**：整合 **Ruff** Linter 與 **Pre-commit** 鉤子，確保實驗代碼不影響系統穩定性。
*   **CI/CD 優化**：GitHub Actions 具備路徑過濾機制，精準執行代碼檢查，大幅減少等待時間。

---

## 🛠️ 快速開始 (Quick Start)

### 1. 啟動環境
```bash
cp deploy/.env.example .env  # 從部署資料夾複製範本
make start                   # 啟動全容器環境 (背景執行)
```

### 2. 建立專家大腦
```bash
make sync-modelfile
make build-brain     # 建立 'gemma4-comfy-expert' 專家模型
```

### 3. 行動端 API (選填)
```bash
make api-server      # 啟動行動端閘道器 (Port 8000)
```

---

## 🏗️ 終極指令集 (The Master Commands)

| 指令 | 說明 |
| :--- | :--- |
| `make dashboard` | **[NEW]** 啟動專業 TUI 儀表板，實時監看 GPU 狀態 |
| `make flush` | **[NEW]** 一鍵洗滌顯存，強制回收 GPU 殘留資源 |
| `make status` | 實時查看所有容器健康度與資源佔用 (CPU/MEM) |
| `make build-brain`| 將 Gemma 4 轉化為具備無審查創意能力的「生圖大師」 |
| `make update-nodes`| [極速] 4 進程並行更新所有 ComfyUI 自訂節點 |
| `make doctor` | 執行系統全方位診斷，包含 GPU 映射、網路連通性與磁碟空間 |
| `make check` | **[NEW]** 本地代碼品質檢查 (Ruff + Compose Config) |

---

## 🛠️ 開發者指南 (Developer Guide)

本專案採用嚴格的代碼品質控管，請開發者遵循以下流程：

1. **環境初始化**：
   使用 `uv` 管理依賴，執行 `uv sync` 安裝所有開發套件。
2. **啟動 Pre-commit 鉤子**：
   執行以下指令，確保每次提交前自動執行代碼格式化：
   ```bash
   uv run pre-commit install
   ```
3. **提交前檢查**：
   在 push 程式碼前，建議手動執行 `make check` 確保完全符合規範。

---

## 📜 聲明
本專案為開發者社群分享之研究成果。Gemma 4 模型權利歸 Google 所有，使用請遵守相關社群規範。
