from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import subprocess
from ansi2html import Ansi2HTMLConverter

app = FastAPI()


@app.on_event("startup")
def run_tldr_once() -> None:
    subprocess.getoutput("tldr test")


def ansi_to_html(ansi: str) -> str:
    conv = Ansi2HTMLConverter()
    return conv.convert(ansi)

@app.get("/{name}", response_class=HTMLResponse)
async def tldr(name: str) -> str:
    return ansi_to_html(subprocess.getoutput(f"tldr {name}"))
