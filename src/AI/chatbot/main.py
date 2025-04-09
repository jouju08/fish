from fastapi import FastAPI
from pydantic import BaseModel
from chain.rag_chain import chain_with_history

class ChatRequest(BaseModel):
    question:str
    session_id:str="default"


app = FastAPI()

@app.post("/chat")
async def chat(req:ChatRequest):
    if not req.question.strip():
        raise HTTPException(status_code=400, detail="질문이 비어 있습니다.")

    response = chain_with_history.invoke(
        {"question": req.question},
        config={"configurable": {"session_id": req.session_id}}
    )
    return {"response": response}
