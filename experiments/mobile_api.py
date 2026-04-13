import requests
from fastapi import BackgroundTasks, FastAPI
from pydantic import BaseModel

app = FastAPI(title="Gemma4 Mobile API", description="AI 創作站手機端快捷 API")

OLLAMA_URL = "http://localhost:11434/api/generate"
COMFYUI_URL = "http://localhost:8188/prompt"


class ImageRequest(BaseModel):
    idea: str


def process_image(idea: str):
    print(f"🤖 收到來自手機端的請求: {idea}")

    # 1. 請求 Gemma 4
    system_prompt = (
        "Expand user input into a hyper-detailed Stable Diffusion prompt. "
        "English only. No conversational filler."
    )
    payload = {
        "model": "tripolskypetr/gemma4-uncensored-aggressive",
        "prompt": f"{system_prompt}\nUser: {idea}",
        "stream": False,
    }

    try:
        response = requests.post(OLLAMA_URL, json=payload)
        enhanced_prompt = response.json().get("response", idea)
        print(f"✨ 擴充提示詞: {enhanced_prompt}")

        # 2. 將擴充後的提示詞送給 ComfyUI (這裡僅為架構示意)
        # 實際應用需對應完整的 workflow JSON
        # workflow["6"]["inputs"]["text"] = enhanced_prompt
        # requests.post(COMFYUI_URL, json={"prompt": workflow})

    except Exception as e:
        print(f"❌ API 執行錯誤: {e}")


@app.post("/generate")
async def generate_image(req: ImageRequest, background_tasks: BackgroundTasks):
    background_tasks.add_task(process_image, req.idea)
    return {
        "status": "success",
        "message": "任務已提交背景執行，請稍後至 ComfyUI 查看結果。",
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
