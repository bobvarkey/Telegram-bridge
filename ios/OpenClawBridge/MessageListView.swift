import SwiftUI

struct MessageListView: View {
    @ObservedObject var viewModel: MessageListViewModel
    @State private var messageText = ""

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        Toggle("Urgent only", isOn: $viewModel.filter.priorityOnly)
                            .tint(.red)
                    } header: {
                        Text("Filters")
                    }

                    Section {
                        if viewModel.messages.isEmpty {
                            Text("No messages")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.messages) { message in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(message.chatTitle)
                                            .font(.headline)
                                        Spacer()
                                        PriorityPill(priority: message.priority)
                                    }

                                    Text("\(message.sender): \(message.body)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    Text(message.receivedAt.formatted(date: .omitted, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    } header: {
                        Text("Messages")
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                }

                Divider()

                HStack {
                    TextField("Type message...", text: $messageText)
                        .textFieldStyle(.roundedBorder)

                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundStyle(.white)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .buttonStyle(.bordered)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
            }
            .navigationTitle("OpenClaw Bridge")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(viewModel.isConnected ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        Text(viewModel.isConnected ? "Connected" : "Connecting...")
                            .font(.caption)
                    }
                }
            }
            .task {
                await viewModel.loadMessages()
            }
            .onChange(of: viewModel.filter.priorityOnly) { _ in
                Task { await viewModel.loadMessages() }
            }
        }
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }

        Task {
            await viewModel.sendMessage(text)
            messageText = ""
        }
    }
}

private struct PriorityPill: View {
    let priority: MessagePriority

    var body: some View {
        Text(priority.rawValue.uppercased())
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(backgroundColor.opacity(0.15), in: Capsule())
            .foregroundStyle(backgroundColor)
    }

    private var backgroundColor: Color {
        switch priority {
        case .work: return .blue
        case .personal: return .gray
        case .urgent: return .red
        }
    }
}

#Preview("Inbox") {
    MessageListView(
        viewModel: MessageListViewModel(bridgeService: MockBridgeService())
    )
}
