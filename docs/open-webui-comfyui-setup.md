# 🎨 Open WebUI 串接 ComfyUI 設定指南

本文件詳述如何將 Open WebUI 與後台的 ComfyUI 繪圖引擎進行連線配置，實現「對話即生圖」的自動化流程。

---

## 1. 進入設定介面
1. 登入 Open WebUI (`http://localhost:8080`)。
2. 點擊頁面左下角的 **使用者頭像/名稱**。
3. 選擇 **「設定」 (Settings)** -> **「圖片」 (Images)**。

## 2. 核心連線設定
在「圖片」標籤頁中，進行以下設定：

- **圖片生成開關**：開啟 (綠色)。
- **圖片生成引擎**：選擇 **`ComfyUI`**。
- **ComfyUI 基礎 URL**：輸入 `http://comfyui:8188` (Docker 內部網路) 或 `http://172.19.188.199:8188` (外部網路位址)。

## 3. ComfyUI 工作流程 (Workflow JSON)
在 **「ComfyUI 工作流程」** 欄位中，點擊編輯並貼入以下 **API 格式** 的 JSON。請注意 `{{prompt}}` 是 Open WebUI 用來注入對話指令的變數。

```json
{
  "3": { "class_type": "KSampler", "inputs": { "model": ["4", 0], "positive": ["6", 0], "negative": ["7", 0], "latent_image": ["5", 0] } },
  "4": { "class_type": "CheckpointLoaderSimple", "inputs": { "ckpt_name": "sd_xl_base_1.0.safetensors" } },
  "5": { "class_type": "EmptyLatentImage", "inputs": { "width": 1024, "height": 1024, "batch_size": 1 } },
  "6": { "class_type": "CLIPTextEncode", "inputs": { "text": "{{prompt}}", "clip": ["4", 1] } },
  "7": { "class_type": "CLIPTextEncode", "inputs": { "text": "text, watermark", "clip": ["4", 1] } },
  "8": { "class_type": "VAEDecode", "inputs": { "samples": ["3", 0], "vae": ["4", 2] } },
  "9": { "class_type": "SaveImage", "inputs": { "images": ["8", 0] } }
}
```

## 4. 工作流程節點映射 (Node Mapping)
設定以下編號，讓 Open WebUI 知道該修改 JSON 裡的哪個節點：

| 欄位名稱 | 節點 ID | 說明 |
| :--- | :--- | :--- |
| **Prompt (text)** | **6** | 正面提示詞節點 |
| **Model (ckpt_name)** | **4** | 模型載入節點 |
| **Width (width)** | **5** | 畫布寬度節點 |
| **Height (height)** | **5** | 畫布高度節點 |
| **Seed (seed)** | **3** | 取樣器隨機種子 |

## 5. 常見問題排除 (Troubleshooting)

### Q: 出現 「Value not in list」 錯誤？
- **原因**：JSON 裡的 `ckpt_name` 與您實際擁有的模型檔名不符。
- **解決**：在設定頁面下方的 **「模型」** 下拉選單中，重新選擇一次正確的模型（例如 `sd_xl_base_1.0...`）並儲存。

### Q: 手機或外部設備無法連線？
- **解決**：若是在 WSL2 環境，請在 Windows 以管理員權限執行以下指令進行端口轉發：
  ```powershell
  netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=8188 connectaddress=[您的WSL-IP] connectport=8188
  ```

---
*Last Updated: 2026-04-13*
