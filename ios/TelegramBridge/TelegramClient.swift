import Foundation
import Combine

class TelegramClient: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    @Published var messages: [Message] = []
    @Published var isConnected = false
    @Published var connectionError: String?

    private var webSocket: URLSessionWebSocket?
    private let relaySecret = UserDefaults.standard.string(forKey: "relaySecret") ?? "your-secret-key"
    private let backendURL = UserDefaults.standard.string(forKey: "backendURL") ?? "http://localhost:8000"

    func connect() {
        guard let url = URL(string: "\(backendURL.replacingOccurrences(of: "http", with: "ws"))/ws/sync/iphone") else {
            connectionError = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        webSocket = URLSessionWebSocket(url: url, protocols: [])
        webSocket?.resume()
        receiveMessage()
        isConnected = true
    }

    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        self?.handleMessage(json)
                    }
                case .data(let data):
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        self?.handleMessage(json)
                    }
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                self?.connectionError = error.localizedDescription
                self?.isConnected = false
            }
        }
    }

    private func handleMessage(_ json: [String: Any]) {
        DispatchQueue.main.async {
            if let type = json["type"] as? String, type == "new_message",
               let text = json["text"] as? String,
               let chatId = json["chat_id"] as? Int {
                let message = Message(id: UUID(), chatId: chatId, text: text, timestamp: Date(), source: .telegram)
                self.messages.append(message)
            }
        }
    }

    func sendMessage(text: String, chatId: Int) {
        var request = URLRequest(url: URL(string: "\(backendURL)/api/send-message")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(relaySecret, forHTTPHeaderField: "X-Relay-Token")

        let payload: [String: Any] = [
            "chat_id": chatId,
            "message_text": text,
            "from_device": "iphone"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        URLSession.shared.dataTask(with: request).resume()
    }

    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        isConnected = false
    }
}

struct Message: Identifiable {
    let id: UUID
    let chatId: Int
    let text: String
    let timestamp: Date
    let source: MessageSource

    enum MessageSource {
        case local
        case telegram
        case watch
    }
}
