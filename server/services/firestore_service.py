import firebase_admin
import os
import json
from dotenv import load_dotenv
from firebase_admin import credentials, firestore, auth
from datetime import datetime, timezone

# Load environment variables
load_dotenv()

# Construct service account credentials
service_account_info = {
    "type": "service_account",
    "project_id": os.getenv("GOOGLE_PROJECT_ID"),
    "private_key_id": os.getenv("GOOGLE_PRIVATE_KEY_ID"),
    "private_key": os.getenv("GOOGLE_PRIVATE_KEY").replace('\\n', '\n'),  # Ensure newline formatting
    "client_email": os.getenv("GOOGLE_CLIENT_EMAIL"),
    "client_id": os.getenv("GOOGLE_CLIENT_ID"),
    "auth_uri": os.getenv("GOOGLE_AUTH_URI"),
    "token_uri": os.getenv("GOOGLE_TOKEN_URI"),
    "auth_provider_x509_cert_url": os.getenv("GOOGLE_AUTH_PROVIDER_CERT_URL"),
    "client_x509_cert_url": os.getenv("GOOGLE_CLIENT_CERT_URL"),
    "universe_domain": os.getenv("GOOGLE_UNIVERSE_DOMAIN"),
}

# Convert to JSON (for Firebase SDK or Google Auth Library)
service_account_json = json.dumps(service_account_info, indent=2)

class FirestoreDB:
    def __init__(self):
        # Initialize Firebase Admin SDK
        if not firebase_admin._apps:
            cred = credentials.Certificate(json.loads(service_account_json))
            firebase_admin.initialize_app(cred)
        
        self.db = firestore.client()
    
    def verify_user(self, id_token):
        """Verifies Firebase auth token and returns user UID"""
        try:
            decoded_token = auth.verify_id_token(id_token)
            return decoded_token["uid"]
        except Exception as e:
            print("Auth Error:", e)
            return None
    
    def save_conversation(self, user_id, text, ai_response):
        """Stores conversation in Firestore"""
        user_ref = self.db.collection("users").document(user_id).collection("conversations")
        user_ref.document().set({
            "text": text,
            "ai_response": ai_response,
            "timestamp": datetime.now(timezone.utc)
        })
    
    def get_last_conversations(self, user_id, limit=20):
        """Fetches the last 'limit' conversations and returns them as a string."""
        user_ref = self.db.collection("users").document(user_id).collection("conversations")
        docs = user_ref.order_by("timestamp", direction=firestore.Query.DESCENDING).limit(limit).stream()

        conversations = [
            f"User: {doc.to_dict().get('text', '')}\nAI: {doc.to_dict().get('ai_response', '')}"
            for doc in docs
        ]

        return "\n\n".join(conversations)

    
    def save_emotion(self, user_id, emotion):
        """Stores detected emotion in Firestore"""
        emotion_ref = self.db.collection("users").document(user_id).collection("emotions")
        emotion_ref.document().set({
            "emotion": emotion,
            "timestamp": datetime.now(timezone.utc)
        })
