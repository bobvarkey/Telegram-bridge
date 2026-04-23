import Foundation
import Combine
import WatchKit

class WatchClient: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    @Published var messages: [WatchMessage] = []
    @Published var isConnected = false

    private var webSocket: URLSessionWebSocket?
    private let backendURL = "http://localhost:8000"

    func connect() {
        guard let url = URL(string: "\(backendURL.replacingOccurrences(of: "http", with: "ws"))/ws/sync/apple-watch") else {
            return
        }

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
            case .failure:
                self?.isConnected = false
            }
        }
    }

    private func handleMessage(_ json: [String: Any]) {
        DispatchQueue.main.async {
            if let type = json["type"] as? String, type == "new_message",
               let text = json["text"] as? String,
               let chatId = json["chat_id"] as? Int {
                let message = WatchMessage(id: UUID(), text: text, chatId: chatId, timestamp: Date())
                self.messages.append(message)
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }

    func sendMessage(text: String, chatId: Int) {
        var request = URLRequest(url: URL(string: "\(backendURL)/api/send-message")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("your-secret-key", forHTTPHeaderField: "X-Relay-Token")

        let payload: [String: Any] = [
            "chat_id": chatId,
            "message_text": text,
            "from_device": "apple-watch"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        URLSession.shared.dataTask(with: request).resume()
    }

    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        isConnected = false
    }
}

struct WatchMessage: Identifiable {
    let id: UUID
    let text: String
    let chatId: Int
    let timestamp: Date
}
