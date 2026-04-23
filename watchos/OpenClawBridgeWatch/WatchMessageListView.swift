import SwiftUI

struct WatchMessageListView: View {
    let messages: [WatchMessage]

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

struct WatchMessage: Identifiable {
    let id = UUID()
    let chatTitle: String
    let body: String
}

enum SampleWatchData {
    static let messages: [WatchMessage] = [
        WatchMessage(chatTitle: "Ops", body: "CPU alert: node 3"),
        WatchMessage(chatTitle: "Family", body: "On our way home"),
        WatchMessage(chatTitle: "Dev Team", body: "PR merged")
    ]
}

#Preview("Watch Inbox") {
    WatchMessageListView(messages: SampleWatchData.messages)
}
