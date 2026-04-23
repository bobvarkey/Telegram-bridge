import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject var watchClient: WatchClient
    @State private var messageText = ""
    @State private var showReplySheet = false

    var body: some View {
        VStack(spacing: 0) {
            if !watchClient.messages.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(watchClient.messages.suffix(5)) { msg in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(msg.text)
                                    .font(.caption)
                                    .lineLimit(2)
                                Text(msg.timestamp.formatted(date: .omitted, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                        }
                    }
                    .padding(4)
                }
            } else {
                VStack {
                    Image(systemName: "message.fill")
                        .font(.title3)
                    Text("No messages")
                        .font(.caption)
                }
                .frame(maxHeight: .infinity)
            }

            Divider()

            HStack(spacing: 4) {
                Button(action: { showReplySheet = true }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title3)
                }
                .sheet(isPresented: $showReplySheet) {
                    ReplyView(isPresented: $showReplySheet, messageText: $messageText) {
                        watchClient.sendMessage(text: messageText, chatId: 0)
                        messageText = ""
                    }
                }

                Button(action: {
                    if watchClient.isConnected {
                        watchClient.disconnect()
                    } else {
                        watchClient.connect()
                    }
                }) {
                    Image(systemName: watchClient.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(watchClient.isConnected ? .green : .red)
                }
            }
            .padding(4)
        }
        .onAppear {
            watchClient.connect()
        }
    }
}

struct ReplyView: View {
    @Binding var isPresented: Bool
    @Binding var messageText: String
    let onSend: () -> Void

    var body: some View {
        VStack {
            TextField("Reply...", text: $messageText)
                .textFieldStyle(.roundedBorder)
                .font(.caption)

            HStack {
                Button("Cancel") { isPresented = false }
                Button("Send") {
                    onSend()
                    isPresented = false
                }
                .disabled(messageText.isEmpty)
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    WatchContentView()
        .environmentObject(WatchClient())
}
