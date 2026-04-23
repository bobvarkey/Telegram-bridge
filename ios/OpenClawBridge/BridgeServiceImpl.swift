import Foundation
import WebKit

actor BridgeServiceImpl: BridgeService {
    private let backendURL: String
    private let relayToken: String
    private let chatID: Int
    private let deviceID: String

    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnected = false
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 10
    private var messageCache: [String: BridgeMessage] = [:]

    init(backendURL: String, relayToken: String, chatID: Int) {
        self.backendURL = backendURL
        self.relayToken = relayToken
        self.chatID = chatID
        self.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }

    func connect(onMessage: @escaping ([BridgeMessage]) -> Void) async {
        await startWebSocketConnection(onMessage: onMessage)
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

    func sendMessage(_ text: String) async throws {
        guard let url = URL(string: "\(backendURL)/api/send-message") else {
            throw BridgeError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(relayToken, forHTTPHeaderField: "x-relay-token")

        let payload = [
            "chat_id": chatID,
            "message_text": text,
            "from_device": deviceID
        ] as [String: Any]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw BridgeError.sendFailed
        }
    }

    func fetchMessages(filter: BridgeFilter) async throws -> [BridgeMessage] {
        guard let url = URL(string: "\(backendURL)/api/messages/\(chatID)?limit=10") else {
            throw BridgeError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(relayToken, forHTTPHeaderField: "x-relay-token")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw BridgeError.fetchFailed
        }

        // For now, return cached messages. In production, parse the API response.
        return Array(messageCache.values).sorted { $0.timestamp > $1.timestamp }
    }

    func setupWebhook(webhookURL: String) async throws {
        guard let url = URL(string: "\(backendURL)/api/setup-webhook") else {
            throw BridgeError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(relayToken, forHTTPHeaderField: "x-relay-token")

        let payload = ["webhook_url": webhookURL]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw BridgeError.setupFailed
        }
    }

    private func startWebSocketConnection(onMessage: @escaping ([BridgeMessage]) -> Void) async {
        guard let url = URL(string: "\(backendURL.replacingOccurrences(of: "http", with: "ws"))/ws/sync/\(deviceID)") else {
            return
        }

        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        reconnectAttempts = 0

        await receiveMessages(onMessage: onMessage)
    }

    private func receiveMessages(onMessage: @escaping ([BridgeMessage]) -> Void) async {
        while isConnected {
            do {
                let message = try await webSocketTask?.receive()
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        await processWebSocketMessage(json, onMessage: onMessage)
                    }
                case .data(let data):
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        await processWebSocketMessage(json, onMessage: onMessage)
                    }
                case .none:
                    isConnected = false
                @unknown default:
                    break
                }
            } catch {
                isConnected = false
                await reconnectWithBackoff(onMessage: onMessage)
            }
        }
    }

    private func processWebSocketMessage(_ json: [String: Any], onMessage: @escaping ([BridgeMessage]) -> Void) async {
        guard let type = json["type"] as? String, type == "new_message" else { return }
        guard let chatId = json["chat_id"] as? Int, chatId == chatID else { return }
        guard let text = json["text"] as? String else { return }

        let messageID = UUID()
        let message = BridgeMessage(
            id: messageID,
            chatTitle: "Telegram",
            sender: "Contact",
            body: text,
            receivedAt: Date(),
            priority: .work
        )

        messageCache[messageID.uuidString] = message
        onMessage(Array(messageCache.values).sorted { $0.receivedAt > $1.receivedAt })
    }

    private func reconnectWithBackoff(onMessage: @escaping ([BridgeMessage]) -> Void) async {
        guard reconnectAttempts < maxReconnectAttempts else { return }

        reconnectAttempts += 1
        let delay = min(1 << reconnectAttempts, 30) + Double.random(in: 0..<1)

        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        await startWebSocketConnection(onMessage: onMessage)
    }
}

enum BridgeError: LocalizedError {
    case invalidURL
    case sendFailed
    case fetchFailed
    case setupFailed
    case connectionFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid backend URL"
        case .sendFailed: return "Failed to send message"
        case .fetchFailed: return "Failed to fetch messages"
        case .setupFailed: return "Failed to setup webhook"
        case .connectionFailed: return "Connection failed"
        }
    }
}
