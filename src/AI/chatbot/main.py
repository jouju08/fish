from fastapi import FastAPI
from pydantic import BaseModel
from chain.rag_chain import chain_with_history

class ChatRequest(BaseModel):
    question:str
    session_id:str="default"


app = FastAPI()

@app.post("/chat")
async def chat(req:ChatRequest):
    response = chain_with_history.invoke(
        {"question": req.question},
        config={"configurable": {"session_id": req.session_id}}
    )
    return {"response": response}