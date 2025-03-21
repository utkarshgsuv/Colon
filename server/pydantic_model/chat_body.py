from pydantic import BaseModel

class ChatBody(BaseModel):
    query: str  # User's text input
    mood: str   # Detected mood (e.g., "happy", "sad", "angry")
    id_token: str  # Firebase authentication token
