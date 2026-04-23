import Foundation

protocol BridgeService {
    func fetchMessages(filter: BridgeFilter) async throws -> [BridgeMessage]
    func sendMessage(_ text: String) async throws
    func connect(onMessage: @escaping ([BridgeMessage]) -> Void) async
    func disconnect()
    func setupWebhook(webhookURL: String) async throws
}

struct MockBridgeService: BridgeService {
    func fetchMessages(filter: BridgeFilter) async throws -> [BridgeMessage] {
        let base = [
            BridgeMessage(chatTitle: "Dev Team", sender: "Alex", body: "Standup in 10 min", priority: .work),
            BridgeMessage(chatTitle: "Family", sender: "Sam", body: "Dinner at 7?", priority: .personal),
            BridgeMessage(chatTitle: "Ops", sender: "Bot", body: "Latency spike detected", priority: .urgent)
        ]

        return base.filter { message in
            if filter.priorityOnly && message.priority != .urgent {
                return false
            }

            if !filter.allowedChats.isEmpty && !filter.allowedChats.contains(message.chatTitle) {
                return false
            }

            if filter.keywords.isEmpty {
                return true
            }

            let lowerBody = message.body.lowercased()
            return filter.keywords.contains { lowerBody.contains($0.lowercased()) }
        }
    }

    func sendMessage(_ text: String) async throws {}
    func connect(onMessage: @escaping ([BridgeMessage]) -> Void) async {}
    func disconnect() {}
    func setupWebhook(webhookURL: String) async throws {}
}
