import SwiftUI

struct WatchMessageListView: View {
    let messages: [BridgeMessage]

    var body: some View {
        List(messages) { message in
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(message.chatTitle)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
                Text(message.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(.vertical, 2)
        }
    }
}

enum SampleWatchData {
    static let messages: [BridgeMessage] = [
        BridgeMessage(chatTitle: "Ops", sender: "Bot", body: "CPU alert: node 3", priority: .urgent),
        BridgeMessage(chatTitle: "Family", sender: "Sam", body: "On our way home", priority: .personal),
        BridgeMessage(chatTitle: "Dev Team", sender: "Alex", body: "PR merged", priority: .work)
    ]
}

#Preview("Watch Inbox") {
    WatchMessageListView(messages: SampleWatchData.messages)
}
