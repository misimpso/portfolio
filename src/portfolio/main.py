from typing import Set
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from pathlib import Path
from pydantic import BaseSettings

STATIC_FILES_PATH: Path = (Path(__file__).parent / "static").absolute()
TEMPLATES_FILES_PATH: Path = (Path(__file__).parent / "templates").absolute()


class Settings(BaseSettings):
    openapi_url: str = "/openapi.json"


settings = Settings()
app = FastAPI(openapi_url=settings.openapi_url)
app.mount("/static", StaticFiles(directory=STATIC_FILES_PATH), name="static")
templates = Jinja2Templates(directory=TEMPLATES_FILES_PATH)


@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})
