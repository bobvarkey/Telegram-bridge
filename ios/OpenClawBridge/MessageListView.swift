import SwiftUI

struct MessageListView: View {
    @ObservedObject var viewModel: MessageListViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Urgent only", isOn: $viewModel.filter.priorityOnly)
                        .tint(.red)
                } header: {
                    Text("Filters")
                }

                Section {
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
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Messages")
                }
            }
            .navigationTitle("OpenClaw Bridge")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "bolt.badge.clock")
                        .foregroundStyle(.red)
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
