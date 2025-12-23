from mangum import Mangum
from fastapi import FastAPI
from api.users import router as user_router

app = FastAPI(
    title="FastAPI DynamoDB CRUD",
    description="CRUD operations for Users table in DynamoDB",
    version="1.0.0"
)

app.include_router(user_router)


@app.get("/")
def health_check():
    return {
        "status": "running",
        "service": "FastAPI DynamoDB CRUD API"
    }

# Lambda handler
handler = Mangum(app)
