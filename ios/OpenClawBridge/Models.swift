import Foundation

enum MessagePriority: String, Codable, CaseIterable {
    case work = "Work"
    case personal = "Personal"
    case urgent = "Urgent"
}

struct BridgeMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let chatTitle: String
    let sender: String
    let body: String
    let receivedAt: Date
    let priority: MessagePriority

    init(
        id: UUID = UUID(),
        chatTitle: String,
        sender: String,
        body: String,
        receivedAt: Date = .now,
        priority: MessagePriority = .personal
    ) {
        self.id = id
        self.chatTitle = chatTitle
        self.sender = sender
        self.body = body
        self.receivedAt = receivedAt
        self.priority = priority
    }
}

struct BridgeFilter: Codable, Hashable {
    var allowedChats: Set<String> = []
    var keywords: Set<String> = []
    var priorityOnly: Bool = false
}
