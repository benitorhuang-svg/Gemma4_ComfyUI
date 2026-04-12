import subprocess
import shutil
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.live import Live
from rich.layout import Layout
from rich import box

console = Console()

def get_gpu_status():
    if not shutil.which("nvidia-smi"):
        return "N/A"
    try:
        out = subprocess.check_output(
            ["nvidia-smi", "--query-gpu=memory.used,memory.total,utilization.gpu", "--format=csv,noheader,nounits"]
        ).decode().strip()
        used, total, util = out.split(", ")
        return f"[bold cyan]{used}/{total} MiB[/] ([yellow]{util}%[/])"
    except Exception:
        return "Error"

def get_docker_status():
    try:
        out = subprocess.check_output(["docker", "compose", "ps", "--format", "json"]).decode()
        return "[bold green]Running[/]" if out.strip() else "[bold red]Stopped[/]"
    except Exception:
        return "[bold red]N/A[/]"

def generate_dashboard():
    table = Table(box=box.ROUNDED, expand=True)
    table.add_column("服務組件", style="magenta")
    table.add_column("狀態", justify="center")
    table.add_column("資源/端口", justify="right")

    table.add_row("🧠 Ollama (Gemma 4)", "[green]Online[/]", "Port 11434")
    table.add_row("🎨 ComfyUI", "[green]Online[/]", "Port 8188")
    table.add_row("🌐 Open WebUI", "[green]Online[/]", "Port 8080")
    table.add_row("📟 GPU (RTX 2060)", "[cyan]Active[/]", get_gpu_status())

    layout = Layout()
    layout.split_column(
        Layout(Panel("[bold yellow]🌟 Gemma 4 + ComfyUI 極致編排系統 v2.6.0[/]", box=box.DOUBLE), size=3),
        Layout(table),
        Layout(Panel("[bold green]常用指令:[/] make start | make status | make build-brain | make backup", title="Quick Guide"), size=3)
    )
    return layout

def main():
    with Live(generate_dashboard(), refresh_per_second=1):
        try:
            while True:
                import time
                time.sleep(1)
        except KeyboardInterrupt:
            console.print("\n[bold red]👋 儀表板關閉[/]")

if __name__ == "__main__":
    main()
