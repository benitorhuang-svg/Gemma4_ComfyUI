import os
import sys
import time
from pyngrok import ngrok

def start_share():
    token = os.environ.get("NGROK_TOKEN")
    auth = os.environ.get("NGROK_AUTH")
    
    if not token:
        print("❌ 錯誤: 未在 .env 中設定 NGROK_TOKEN，請前往 https://dashboard.ngrok.com 獲取。")
        sys.exit(1)

    ngrok.set_auth_token(token)
    
    print("⏳ 正在啟動 ngrok 通道...")
    try:
        # Configuration for basic auth if provided
        options = {"auth": auth} if auth else {}
        
        # Expose Open WebUI (Port 8080)
        webui_url = ngrok.connect(8080, "http", **options).public_url
        print(f"🚀 Open WebUI 外部網址: {webui_url}")

        # Expose ComfyUI (Port 8188)
        comfyui_url = ngrok.connect(8188, "http", **options).public_url
        print(f"🎨 ComfyUI 外部網址: {comfyui_url}")
        
        if auth:
            print(f"🔐 已啟動 Basic Auth 安全鎖。帳號密碼為: {auth}")
        else:
            print("⚠️ 警告: 目前未設定 NGROK_AUTH，網址是公開且無保護的！建議在 .env 中設定。")
            
        print("\n💡 請保持此視窗開啟以維持連線。按 Ctrl+C 停止分享。")
        
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n👋 停止分享...")
    except Exception as e:
        print(f"\n❌ 發生錯誤: {e}")
    finally:
        ngrok.kill()

if __name__ == "__main__":
    start_share()
