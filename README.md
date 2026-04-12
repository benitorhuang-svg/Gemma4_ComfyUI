# 🚀 Gemma 4 + ComfyUI + Open WebUI：全方位 AI 創作工作站 (v2.6.0)

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
| **Mobile API** | **閘道 (Gateway)** | 行動端快捷 API，支援 iOS 捷徑語音生圖。 | `:8000` |

---

## ✨ 卓越優化黑科技 (Optimization Features)

### 1. 📟 6GB 顯存「接力賽」調度 (RTX 2060 Optimized)
*   **0s Keep-Alive**：專為 6GB 顯卡設計。Gemma 4 生成提示詞後立即釋放 VRAM，將整張顯示卡讓給 ComfyUI 繪圖。
*   **TensorRT 加速**：內建 `ComfyUI-TensorRT` 支援，將生圖速度提升 **50% - 100%**。
*   **CUDA 記憶體優化**：啟用 `expandable_segments`，有效防止顯存碎片化導致的崩潰。

### 2. 🌍 全球私有雲連線 (Zero Trust Network)
*   **Tailscale 整合**：內建 `scripts/setup_tailscale.sh`。無需公網 IP，即可從手機、平板在全球任何地方安全連回您的工作站。

### 3. ⚡ 極速自動化 (Automation & DevOps)
*   **全域鏡像源**：Apt、Pip、UV 下載皆鎖定高速鏡像站，2.5GB 的 PyTorch 下載不再是噩夢。
*   **自癒啟動引擎**：自動安裝插件依賴，並偵測 VRAM 動態切換 `--lowvram` 模式。
*   **TCMalloc 加強**：解決長時運行內存洩漏，穩定性提升。

---

## 🛠️ 快速開始 (Quick Start)

### 1. 啟動環境
```bash
cp .env.example .env  # 填寫 NGROK_TOKEN (或使用 Tailscale)
make start           # 啟動全容器環境 (背景執行)
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
| `python main.py` | **[NEW]** 啟動專業 TUI 儀表板，實時監看 GPU 狀態 |
| `make flush` | **[NEW]** 一鍵洗滌顯存，強制回收 GPU 殘留資源 |
| `make status` | 實時查看所有容器健康度與資源佔用 (CPU/MEM) |
| `make build-brain`| 將 Gemma 4 轉化為具備無審查創意能力的「生圖大師」 |
| `make update-nodes`| [極速] 4 進程並行更新所有 ComfyUI 自訂節點 |
| `make doctor` | 執行系統全方位診斷，一鍵排查配置問題 |

---

## 📜 聲明
本專案為開發者社群分享之研究成果。Gemma 4 模型權利歸 Google 所有，使用請遵守相關社群規範。
