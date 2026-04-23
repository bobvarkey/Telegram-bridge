"""OpenClaw Bridge Telegram bot relay starter.

Usage:
  export TELEGRAM_BOT_TOKEN=... 
  export OPENCLAW_BRIDGE_ENDPOINT=https://your-bridge-api/send
  python bot_listener.py
"""

from __future__ import annotations

import os

import requests
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, MessageHandler, filters

BRIDGE_ENDPOINT = os.getenv("OPENCLAW_BRIDGE_ENDPOINT", "")
BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "")


async def mirror(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if update.message is None or update.message.text is None:
        return

    payload = {
        "message": update.message.text,
        "chat_id": update.effective_chat.id if update.effective_chat else None,
        "sender": update.effective_user.username if update.effective_user else None,
    }

    if BRIDGE_ENDPOINT:
        requests.post(BRIDGE_ENDPOINT, json=payload, timeout=5)

    print(f"Mirrored message from {payload['sender']}: {payload['message']}")


def main() -> None:
    if not BOT_TOKEN:
        raise RuntimeError("Set TELEGRAM_BOT_TOKEN before starting the listener.")

    app = ApplicationBuilder().token(BOT_TOKEN).build()
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, mirror))
    app.run_polling()


if __name__ == "__main__":
    main()
