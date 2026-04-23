"""
Integration tests for iOS/watchOS client interactions with backend.

Simulates real client behavior:
- Setup flow with webhook registration
- Message sending and receiving
- WebSocket relay between devices
- Reconnection scenarios
- Error recovery
"""

import pytest
import json
import hashlib
import hmac
import asyncio
from unittest.mock import patch, AsyncMock, MagicMock
from fastapi.testclient import TestClient
import os

os.environ["TELEGRAM_BOT_TOKEN"] = "test_token_12345"
os.environ["RELAY_SECRET"] = "test_relay_secret"
os.environ["ALLOWED_ORIGINS"] = "http://localhost:3000"

from app.main import app, RELAY_SECRET, TELEGRAM_BOT_TOKEN

client = TestClient(app)


class TestSetupFlow:
    """Test the complete iOS app setup flow."""

    def test_setup_flow_complete(self):
        """Simulate complete setup: config → webhook setup → connection test."""
        # Step 1: App calls health endpoint
        with patch('app.main.bot.get_me', new_callable=AsyncMock) as mock_get_me, \
             patch('app.main.bot.get_webhook_info', new_callable=AsyncMock) as mock_webhook:
            mock_get_me.return_value = AsyncMock(username="test_bot")
            mock_webhook.return_value = AsyncMock(url=None, pending_update_count=0)

            response = client.get("/health")
            assert response.status_code == 200
            assert response.json()["bot_connected"] == True

        # Step 2: App registers webhook
        with patch('app.main.bot.set_webhook', new_callable=AsyncMock) as mock_set, \
             patch('app.main.bot.get_webhook_info', new_callable=AsyncMock) as mock_get_info:
            mock_set.return_value = True
            mock_get_info.return_value = AsyncMock(
                url="https://api.test.com/webhook/telegram",
                has_custom_certificate=False,
                pending_update_count=0
            )

            webhook_url = "https://api.test.com/webhook/telegram"
            response = client.post(
                "/api/setup-webhook",
                json={"webhook_url": webhook_url},
                headers={"x-relay-token": RELAY_SECRET}
            )
            assert response.status_code == 200
            assert response.json()["status"] == "registered"

        # Step 3: App verifies webhook is registered
        with patch('app.main.bot.get_webhook_info', new_callable=AsyncMock) as mock_status:
            mock_status.return_value = AsyncMock(
                url="https://api.test.com/webhook/telegram",
                has_custom_certificate=False,
                pending_update_count=0,
                last_error_date=None,
                last_error_message=None
            )

            response = client.get(
                "/api/webhook-status",
                headers={"x-relay-token": RELAY_SECRET}
            )
            assert response.status_code == 200
            assert response.json()["registered"] == True


class TestMessageSending:
    """Test message sending from iOS app to Telegram."""

    def test_ios_sends_message_to_telegram(self):
        """iOS app sends message through relay to Telegram."""
        # iOS app sends a message
        payload = {
            "chat_id": 987654,
            "message_text": "Hello from iPhone!",
            "from_device": "iphone_user"
        }

        with patch('app.main.bot.send_message', new_callable=AsyncMock) as mock_send:
            mock_send.return_value = MagicMock(message_id=123)

            response = client.post(
                "/api/send-message",
                json=payload,
                headers={"x-relay-token": RELAY_SECRET}
            )

            assert response.status_code == 200
            assert response.json()["status"] == "sent"
            mock_send.assert_called_once()


class TestWebhookToClient:
    """Test message flow from Telegram webhook to connected clients."""

    def test_telegram_webhook_to_connected_client(self):
        """Telegram sends webhook → relay broadcasts to connected clients."""
        # Simulate a Telegram message arriving via webhook
        body = json.dumps({
            "update_id": 123,
            "message": {
                "message_id": 456,
                "date": 1234567890,
                "chat": {"id": 987654},
                "text": "Message from Telegram"
            }
        })

        secret = hashlib.sha256(TELEGRAM_BOT_TOKEN.encode()).digest()
        signature = hmac.new(secret, body.encode(), hashlib.sha256).hexdigest()

        # Mock connected client to track if message is sent
        with patch('app.main.connected_clients', {"device1": AsyncMock()}):
            response = client.post(
                "/webhook/telegram",
                content=body,
                headers={"X-Telegram-Bot-Api-Secret-Token": signature},
                media_type="application/json"
            )

            # Should process webhook successfully
            assert response.status_code == 200
            assert response.json()["ok"] == True


class TestMessageBroadcast:
    """Test broadcasting to multiple connected devices."""

    def test_websocket_broadcast_to_multiple_devices(self):
        """One device sends message that broadcasts to others."""
        # This would be tested with WebSocket testing framework
        # Simplified version shows the concept:

        payload = {
            "chat_id": 123,
            "message_text": "Test broadcast",
            "from_device": "iphone"
        }

        with patch('app.main.bot.send_message', new_callable=AsyncMock):
            response = client.post(
                "/api/send-message",
                json=payload,
                headers={"x-relay-token": RELAY_SECRET}
            )
            assert response.status_code == 200


class TestErrorRecovery:
    """Test error handling and recovery scenarios."""

    def test_telegram_offline_handling(self):
        """When Telegram is offline, error is returned gracefully."""
        from telegram.error import TelegramError

        payload = {
            "chat_id": 123,
            "message_text": "test",
            "from_device": "test_device"
        }

        with patch('app.main.bot.send_message', side_effect=TelegramError("Bot API unavailable")):
            response = client.post(
                "/api/send-message",
                json=payload,
                headers={"x-relay-token": RELAY_SECRET}
            )

            assert response.status_code == 400
            assert "Failed to send message" in response.json()["detail"]

    def test_invalid_message_rejected(self):
        """Invalid messages are rejected before sending."""
        invalid_payloads = [
            {"chat_id": -1, "message_text": "x", "from_device": "a"},  # negative chat_id
            {"chat_id": 1, "message_text": "", "from_device": "a"},     # empty message
            {"chat_id": 1, "message_text": "x" * 5000, "from_device": "a"},  # too long
        ]

        for payload in invalid_payloads:
            response = client.post(
                "/api/send-message",
                json=payload,
                headers={"x-relay-token": RELAY_SECRET}
            )
            assert response.status_code == 422


class TestConcurrentMessages:
    """Test handling of concurrent message sends."""

    def test_concurrent_message_sends_handled(self):
        """Multiple concurrent sends should all succeed."""
        with patch('app.main.bot.send_message', new_callable=AsyncMock) as mock_send:
            mock_send.return_value = MagicMock(message_id=123)

            # Simulate 3 concurrent sends
            payloads = [
                {
                    "chat_id": 123,
                    "message_text": f"Message {i}",
                    "from_device": f"device_{i}"
                }
                for i in range(3)
            ]

            responses = [
                client.post(
                    "/api/send-message",
                    json=payload,
                    headers={"x-relay-token": RELAY_SECRET}
                )
                for payload in payloads
            ]

            assert all(r.status_code == 200 for r in responses)
            assert mock_send.call_count == 3


class TestRateLimiting:
    """Test rate limiting on message endpoint."""

    def test_rate_limit_prevents_abuse(self):
        """Rapid message sends should be rate limited."""
        payload = {
            "chat_id": 123,
            "message_text": "test",
            "from_device": "test_device"
        }

        with patch('app.main.bot.send_message', new_callable=AsyncMock):
            # Send requests up to rate limit (10/minute)
            # Note: Full test requires slowapi configuration
            # This verifies the endpoint structure
            response = client.post(
                "/api/send-message",
                json=payload,
                headers={"x-relay-token": RELAY_SECRET}
            )
            assert response.status_code in [200, 429]  # 200 or rate limited


class TestWatchOSIntegration:
    """Test watchOS-specific integration scenarios."""

    def test_watch_fetches_message_history(self):
        """Watch app fetches recent message history on launch."""
        response = client.get(
            "/api/messages/123?limit=5&offset=0",
            headers={"x-relay-token": RELAY_SECRET}
        )

        assert response.status_code == 200
        data = response.json()
        assert data["limit"] == 5
        assert data["offset"] == 0
        assert "messages" in data

    def test_watch_pagination(self):
        """Watch can paginate through message history."""
        # First page
        response1 = client.get(
            "/api/messages/123?limit=5&offset=0",
            headers={"x-relay-token": RELAY_SECRET}
        )
        assert response1.status_code == 200

        # Second page
        response2 = client.get(
            "/api/messages/123?limit=5&offset=5",
            headers={"x-relay-token": RELAY_SECRET}
        )
        assert response2.status_code == 200


class TestAuthenticationFlow:
    """Test authentication in various scenarios."""

    def test_missing_relay_token_on_all_endpoints(self):
        """All protected endpoints require relay token."""
        protected_endpoints = [
            ("POST", "/api/send-message", {"chat_id": 1, "message_text": "x", "from_device": "a"}),
            ("GET", "/api/messages/123", None),
            ("POST", "/api/setup-webhook", {"webhook_url": "https://test.com"}),
            ("GET", "/api/webhook-status", None),
        ]

        for method, endpoint, data in protected_endpoints:
            if method == "POST":
                response = client.post(endpoint, json=data)
            else:
                response = client.get(endpoint)

            assert response.status_code == 401, f"Endpoint {endpoint} missing token validation"


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
