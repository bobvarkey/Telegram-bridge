from fastapi import FastAPI, HTTPException, Header, WebSocket, WebSocketDisconnect, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional
import os
import logging
from dotenv import load_dotenv
from telegram import Bot
from telegram.error import TelegramError
from slowapi import Limiter
from slowapi.util import get_remote_address
import json
import asyncio
import hashlib
import hmac

load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Telegram Bridge Relay")

# Initialize rate limiter
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

# FIX #1: Configure CORS with specific origins (not wildcard)
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["POST", "GET", "OPTIONS"],
    allow_headers=["Content-Type", "x-relay-token"],
)

# FIX #2: Require RELAY_SECRET (no default value)
TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
RELAY_SECRET = os.getenv("RELAY_SECRET")

if not TELEGRAM_BOT_TOKEN:
    raise ValueError("TELEGRAM_BOT_TOKEN environment variable must be set")

if not RELAY_SECRET:
    raise ValueError("RELAY_SECRET environment variable must be set")

bot = Bot(token=TELEGRAM_BOT_TOKEN)

# FIX #5: Add input validation (message length, chat_id range)
class Message(BaseModel):
    chat_id: int = Field(..., gt=0, description="Telegram chat ID")
    message_text: str = Field(
        ...,
        min_length=1,
        max_length=4096,  # Telegram's max message length
        description="Message text (1-4096 characters)"
    )
    from_device: str = Field(
        ...,
        min_length=1,
        max_length=50,
        description="Device identifier"
    )

class TelegramUpdate(BaseModel):
    update_id: int
    message: Optional[dict] = None

connected_clients = {}

@app.on_event("startup")
async def startup():
    if not TELEGRAM_BOT_TOKEN:
        raise ValueError("TELEGRAM_BOT_TOKEN not set")
    print(f"Bot connected as @{(await bot.get_me()).username}")

# FIX #3: Add rate limiting to prevent abuse
@app.post("/api/send-message")
@limiter.limit("10/minute")
async def send_message(msg: Message, x_relay_token: str = Header(None)):
    if x_relay_token != RELAY_SECRET:
        logger.warning("Unauthorized send-message attempt")
        raise HTTPException(status_code=401, detail="Unauthorized")

    try:
        await bot.send_message(chat_id=msg.chat_id, text=msg.message_text)
        logger.info(f"Message sent from {msg.from_device} to chat {msg.chat_id}")
        return {"status": "sent", "device": msg.from_device}
    except TelegramError as e:
        logger.error(f"Telegram error: {e}")
        raise HTTPException(status_code=400, detail="Failed to send message")
    except Exception as e:
        logger.error(f"Unexpected error sending message: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/api/messages/{chat_id}")
async def get_messages(
    chat_id: int,
    limit: int = 10,
    offset: int = 0,
    x_relay_token: str = Header(None)
):
    if x_relay_token != RELAY_SECRET:
        raise HTTPException(status_code=401, detail="Unauthorized")

    if limit < 1 or limit > 100:
        limit = 10
    if offset < 0:
        offset = 0

    logger.info(f"Fetching messages for chat {chat_id}, limit={limit}, offset={offset}")

    return {
        "chat_id": chat_id,
        "messages": [],
        "limit": limit,
        "offset": offset,
        "total": 0
    }

# FIX #4: Improve WebSocket error handling
@app.websocket("/ws/sync/{device_id}")
async def websocket_endpoint(websocket: WebSocket, device_id: str):
    try:
        await websocket.accept()
        connected_clients[device_id] = websocket
        logger.info(f"WebSocket client {device_id} connected")
    except Exception as e:
        logger.error(f"Failed to accept WebSocket connection for {device_id}: {e}")
        return

    try:
        while True:
            data = await websocket.receive_text()

            try:
                msg = json.loads(data)
                logger.debug(f"Message from {device_id}: {msg}")
            except json.JSONDecodeError as e:
                logger.warning(f"Invalid JSON from {device_id}: {e}")
                await websocket.send_json({"error": "Invalid message format"})
                continue

            # Broadcast to other clients
            disconnected = []
            for client_id, client_ws in connected_clients.items():
                if client_id != device_id:
                    try:
                        await client_ws.send_json(msg)
                    except Exception as send_error:
                        logger.error(f"Failed to send to {client_id}: {send_error}")
                        disconnected.append(client_id)

            # Clean up disconnected clients
            for client_id in disconnected:
                if client_id in connected_clients:
                    del connected_clients[client_id]
                    logger.info(f"Cleaned up disconnected client {client_id}")

    except WebSocketDisconnect:
        logger.info(f"WebSocket client {device_id} disconnected normally")
    except Exception as e:
        logger.error(f"WebSocket error for {device_id}: {e}", exc_info=True)
    finally:
        if device_id in connected_clients:
            del connected_clients[device_id]
            logger.info(f"WebSocket client {device_id} removed from active clients")

def verify_telegram_signature(body: str) -> bool:
    """Verify that the webhook request came from Telegram using HMAC-SHA256."""
    secret = hashlib.sha256(TELEGRAM_BOT_TOKEN.encode()).digest()
    signature = hmac.new(secret, body.encode(), hashlib.sha256).hexdigest()
    return signature == (os.getenv("X_TELEGRAM_BOT_API_SECRET_TOKEN", ""))

@app.post("/webhook/telegram")
async def telegram_webhook(update: dict, request: Request):
    try:
        body = await request.body()
        body_str = body.decode() if isinstance(body, bytes) else body

        telegram_signature = request.headers.get("X-Telegram-Bot-Api-Secret-Token", "")
        if not telegram_signature:
            logger.warning("Webhook request missing X-Telegram-Bot-Api-Secret-Token header")
            raise HTTPException(status_code=401, detail="Missing signature header")

        secret = hashlib.sha256(TELEGRAM_BOT_TOKEN.encode()).digest()
        expected_signature = hmac.new(secret, body_str.encode(), hashlib.sha256).hexdigest()

        if not hmac.compare_digest(telegram_signature, expected_signature):
            logger.warning("Invalid webhook signature - rejecting request")
            raise HTTPException(status_code=401, detail="Invalid signature")

        if "message" in update:
            msg = update["message"]
            chat_id = msg.get("chat", {}).get("id")
            text = msg.get("text", "")

            if not chat_id:
                logger.warning("Webhook message missing chat_id")
                return {"ok": False}

            webhook_msg = {
                "type": "new_message",
                "chat_id": chat_id,
                "text": text,
                "timestamp": msg.get("date")
            }

            # Broadcast to all connected WebSocket clients
            disconnected = []
            for client_id, client_ws in connected_clients.items():
                try:
                    await client_ws.send_json(webhook_msg)
                except Exception as send_error:
                    logger.error(f"Failed to send webhook to {client_id}: {send_error}")
                    disconnected.append(client_id)

            # Clean up disconnected clients
            for client_id in disconnected:
                if client_id in connected_clients:
                    del connected_clients[client_id]

            logger.info(f"Webhook processed for chat {chat_id}, sent to {len(connected_clients) - len(disconnected)} clients")

        return {"ok": True}
    except Exception as e:
        logger.error(f"Webhook error: {e}", exc_info=True)
        return {"ok": False, "error": str(e)}

@app.post("/api/setup-webhook")
async def setup_webhook(webhook_url: str, x_relay_token: str = Header(None)):
    """Register webhook URL with Telegram Bot API."""
    if x_relay_token != RELAY_SECRET:
        raise HTTPException(status_code=401, detail="Unauthorized")

    try:
        secret_token = hashlib.sha256(TELEGRAM_BOT_TOKEN.encode()).hexdigest()

        response = await bot.set_webhook(
            url=webhook_url,
            secret_token=secret_token,
            allowed_updates=["message"]
        )

        logger.info(f"Webhook registered: {webhook_url}")

        webhook_info = await bot.get_webhook_info()
        return {
            "status": "registered",
            "webhook_url": webhook_info.url,
            "has_custom_certificate": webhook_info.has_custom_certificate,
            "pending_update_count": webhook_info.pending_update_count
        }
    except TelegramError as e:
        logger.error(f"Failed to setup webhook: {e}")
        raise HTTPException(status_code=400, detail=f"Telegram error: {str(e)}")
    except Exception as e:
        logger.error(f"Webhook setup error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to setup webhook")

@app.get("/api/webhook-status")
async def webhook_status(x_relay_token: str = Header(None)):
    """Check webhook registration status."""
    if x_relay_token != RELAY_SECRET:
        raise HTTPException(status_code=401, detail="Unauthorized")

    try:
        info = await bot.get_webhook_info()
        return {
            "registered": bool(info.url),
            "webhook_url": info.url,
            "has_custom_certificate": info.has_custom_certificate,
            "pending_update_count": info.pending_update_count,
            "last_error_date": info.last_error_date,
            "last_error_message": info.last_error_message
        }
    except Exception as e:
        logger.error(f"Webhook status check failed: {e}")
        raise HTTPException(status_code=500, detail="Failed to get webhook status")

@app.get("/health")
async def health():
    try:
        # Check Telegram Bot connectivity
        bot_user = await bot.get_me()
        webhook_info = await bot.get_webhook_info()

        return {
            "status": "healthy",
            "bot_connected": True,
            "bot_username": bot_user.username,
            "webhook_registered": bool(webhook_info.url),
            "active_clients": len(connected_clients)
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return {
            "status": "degraded",
            "bot_connected": False,
            "error": str(e)
        }, 503
