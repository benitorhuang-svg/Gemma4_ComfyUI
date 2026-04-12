import json
import urllib.request
import urllib.parse

# ComfyUI API 存取範例
# 執行前請確保 ComfyUI 正在運行中 (make start)

server_address = "localhost:8188"
client_id = "gemma4_client"

def queue_prompt(prompt):
    p = {"prompt": prompt, "client_id": client_id}
    data = json.dumps(p).encode('utf-8')
    req = urllib.request.Request(f"http://{server_address}/prompt", data=data)
    return json.loads(urllib.request.urlopen(req).read())

def get_history(prompt_id):
    with urllib.request.urlopen(f"http://{server_address}/history/{prompt_id}") as response:
        return json.loads(response.read())

def generate_image_example():
    print(f"🚀 正在發送產圖請求至 {server_address}...")
    
    # 這裡放一個最簡化的穩定擴散工作流 (Workflow JSON)
    # 注意: 下載完 DreamShaper 模型後此腳本才可運作
    prompt_text = "A beautiful sunset over a cyberpunk city, highly detailed, 8k"  # noqa: F841
    
    # 這裡僅為示意架構，實際工作流需從 ComfyUI 匯出的 API JSON 填入
    workflow = {  # noqa: F841
        "3": {
            "class_type": "KSampler",
            "inputs": {
                "seed": 42,
                "steps": 20,
                "cfg": 8,
                "sampler_name": "euler",
                "scheduler": "normal",
                "denoise": 1,
                "model": ["4", 0],
                "positive": ["6", 0],
                "negative": ["7", 0],
                "latent_image": ["5", 0]
            }
        },
        "4": {
            "class_type": "CheckpointLoaderSimple",
            "inputs": {
                "ckpt_name": "DreamShaper_8_pruned.safetensors"
            }
        },
        # ... 這裡需要完整的工作流節點定義
    }
    
    print("💡 提示: 請從 ComfyUI 介面匯出 'API Format' 的 JSON 並填入此腳本。")
    print("目前此腳本僅示範 API 通訊邏輯。")

if __name__ == "__main__":
    generate_image_example()
