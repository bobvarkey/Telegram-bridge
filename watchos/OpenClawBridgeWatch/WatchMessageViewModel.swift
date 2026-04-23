import Foundation

@MainActor
final class WatchMessageViewModel: ObservableObject {
    @Published private(set) var messages: [BridgeMessage] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var isConnected = false

    private let backendURL: String
    private let relayToken: String
    private let chatID: Int

    init(backendURL: String, relayToken: String, chatID: Int = 0) {
        self.backendURL = backendURL
        self.relayToken = relayToken
        self.chatID = chatID
        loadMessages()
    }

    func loadMessages() {
        Task {
            do {
                guard let url = URL(string: "\(backendURL)/api/messages/\(chatID)?limit=5") else {
                    throw BridgeError.invalidURL
                }

                var request = URLRequest(url: url)
                request.setValue(relayToken, forHTTPHeaderField: "x-relay-token")

                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw BridgeError.fetchFailed
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    throw BridgeError.fetchFailed
                }

                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let messagesArray = json["messages"] as? [[String: Any]] {
                    let parsed = messagesArray.compactMap { dict -> BridgeMessage? in
                        guard let text = dict["text"] as? String,
                              let timestamp = dict["timestamp"] as? TimeInterval else {
                            return nil
                        }
                        return BridgeMessage(
                            chatTitle: "Telegram",
                            sender: dict["sender"] as? String ?? "Contact",
                            body: text,
                            receivedAt: Date(timeIntervalSince1970: timestamp),
                            priority: .work
                        )
                    }
                    messages = parsed.sorted { $0.receivedAt > $1.receivedAt }
                    isConnected = true
                    errorMessage = nil
                }

                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                isConnected = false
            }
        }
    }
}
