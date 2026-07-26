from fastapi import FastAPI

app = FastAPI()


@app.get("/api/health")
def health_check():
    return {"status": "ok", "message": "后端运行正常"}