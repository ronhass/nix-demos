from fastapi import FastAPI
import subprocess

app = FastAPI()


@app.get("/{name}")
async def tldr(name: str) -> str:
    return subprocess.getoutput(f"tldr {name}")
