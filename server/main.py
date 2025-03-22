from fastapi import FastAPI
import os
from fastapi.middleware.cors import CORSMiddleware
import asyncio
import httpx

from pydantic_model.chat_body import ChatBody
from services.llm_response import AskLLM
from services.firestore_service import FirestoreDB


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # will Change * to my frontend URL for better security 
    allow_credentials=True,
    allow_methods=["*"],  # Allow POST, GET, OPTIONS, etc.
    allow_headers=["*"],
)

fdb = FirestoreDB()
llm = AskLLM()



async def keep_awake():
    while True:
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    "https://colon-nsxy.onrender.com/hey",
                    json={
  "query": "hi how are you",
  "mood": "neutral",
  "id_token": "cdsdef"
}  # Modify this payload as needed
                )
                print(f"Ping response: {response.status_code} - {response.text}")
        except Exception as e:
            print(f"Ping failed: {e}")
        
        await asyncio.sleep(600)  # Ping every 10 minutes

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(keep_awake())

@app.post("/hey")
def colon_endpoint(body: ChatBody):
    
    try:
        user_id = fdb.verify_user(body.id_token)
        context = fdb.get_last_conversations(user_id )
        if not context:
            context = "This is a new conversation. Respond as if talking to a first-time user."
        fdb.save_emotion(user_id , body.mood)
        response = llm.respond(body.query , context , body.mood)
        fdb.save_conversation(user_id , body.query , response)
        
        return {"summary": response}

        
    except Exception as e:
        print(e)
    
    
    
if __name__ == "__main__":
    import uvicorn
    PORT = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=PORT)

