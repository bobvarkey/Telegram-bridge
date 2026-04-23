import SwiftUI

struct WatchMessageListView: View {
    @ObservedObject var viewModel: WatchMessageViewModel

    var body: some View {
        if viewModel.isLoading {
            VStack(alignment: .center, spacing: 8) {
                ProgressView()
                Text("Loading messages...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else if let errorMessage = viewModel.errorMessage {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
                Text("Error")
                    .font(.headline)
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(action: { viewModel.loadMessages() }) {
                    Text("Retry")
                }
                .padding(.top, 4)
            }
            .padding()
        } else if viewModel.messages.isEmpty {
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "message.circle")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("No messages yet")
                    .font(.headline)
            }
        } else {
            List(viewModel.messages.prefix(5)) { message in
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(message.chatTitle)
                            .font(.headline)
                        Spacer()
                        Circle()
                            .fill(viewModel.isConnected ? Color.green : Color.orange)
                            .frame(width: 6, height: 6)
                    }
                    Text(message.body)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Text(message.receivedAt.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 2)
            }
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
    let viewModel = WatchMessageViewModel(backendURL: "http://localhost", relayToken: "test")
    WatchMessageListView(viewModel: viewModel)
}
