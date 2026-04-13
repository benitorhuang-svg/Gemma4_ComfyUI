import requests

# 配置服務位址 (對應 docker-compose)
OLLAMA_URL = "http://localhost:11434/api/generate"
COMFYUI_URL = "http://localhost:8188/prompt"


def get_gemma4_prompt(user_input):
    """由 Gemma 4 將簡單描述擴充為藝術提示詞"""
    print(f"🤖 Gemma 4 正在思考提示詞: '{user_input}'...")

    system_prompt = (
        "You are an expert AI art prompt engineer. "
        "Expand the user's input into a highly detailed stable diffusion prompt. "
        "Output ONLY the prompt, no conversation."
    )

    payload = {
        "model": "gemma4:e2b",
        "prompt": f"{system_prompt}\nUser Input: {user_input}",
        "stream": False,
    }

    try:
        response = requests.post(OLLAMA_URL, json=payload)
        return response.json().get("response", user_input)
    except Exception as e:
        print(f"❌ Ollama 連線失敗: {e}")
        return user_input


def queue_comfy_image(prompt_text):
    """將提示詞發送給 ComfyUI 進行排隊生圖"""
    print(f"🎨 ComfyUI 正在生成影像，提示詞: \n'{prompt_text[:100]}...'")

    # 這裡是一個簡化的 ComfyUI API 工作流 JSON 結構
    # 實際上您需要從 ComfyUI 介面匯出 "API Format" 的 JSON
    workflow = {  # noqa: F841
        "3": {
            "inputs": {
                "seed": 42,
                "steps": 20,
                "cfg": 7,
                "sampler_name": "euler",
                "scheduler": "normal",
                "denoise": 1,
                "model": ["4", 0],
                "positive": ["6", 0],
                "negative": ["7", 0],
                "latent_image": ["5", 0],
            },
            "class_type": "KSampler",
        },
        "4": {
            "inputs": {"ckpt_name": "DreamShaper_8_pruned.safetensors"},
            "class_type": "CheckpointLoaderSimple",
        },
        "6": {
            "inputs": {"text": prompt_text, "clip": ["4", 1]},
            "class_type": "CLIPTextEncode",
        },
        # ... (省略其他標準節點)
    }

    # 注意：此處僅為結構演示，實際運行需對應完整的 API JSON
    print(
        "💡 提示: 請在 ComfyUI 介面啟用 'Enable Dev mode' 並匯出 API JSON 來替換此處。"
    )


if __name__ == "__main__":
    # 實戰演練
    user_idea = "A futuristic samurai cat in Kyoto"
    enhanced_prompt = get_gemma4_prompt(user_idea)
    print(f"\n✨ Gemma 4 擴充後的提示詞: \n{enhanced_prompt}\n")

    # queue_comfy_image(enhanced_prompt)
