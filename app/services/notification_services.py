import firebase_admin
from firebase_admin import credentials, messaging
import os
from dotenv import load_dotenv

load_dotenv()

def get_firebase_app():
    if firebase_admin._apps:
        return firebase_admin.get_app()

    credential_path = os.getenv("FIREBASE_CREDENTIALS")

    if not credential_path:
        raise RuntimeError("FIREBASE_CREDENTIALS not set")

    if not os.path.exists(credential_path):
        raise RuntimeError(f"Firebase credentials not found: {credential_path}")

    cred = credentials.Certificate(credential_path)
    return firebase_admin.initialize_app(cred)


def send_hearing_notification(token: str, title: str, body: str, data: dict):
    get_firebase_app()

    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        token=token,
        data=data,
    )
    messaging.send(message)
