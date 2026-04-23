import Foundation

public enum MessagePriority: String, Codable, CaseIterable, Sendable {
    case work = "Work"
    case personal = "Personal"
    case urgent = "Urgent"
}

public struct BridgeMessage: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let chatTitle: String
    public let sender: String
    public let body: String
    public let receivedAt: Date
    public let priority: MessagePriority

    public init(
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

public struct BridgeFilter: Codable, Hashable, Sendable {
    public var allowedChats: Set<String>
    public var keywords: Set<String>
    public var priorityOnly: Bool

    public init(
        allowedChats: Set<String> = [],
        keywords: Set<String> = [],
        priorityOnly: Bool = false
    ) {
        self.allowedChats = allowedChats
        self.keywords = keywords
        self.priorityOnly = priorityOnly
    }
}
