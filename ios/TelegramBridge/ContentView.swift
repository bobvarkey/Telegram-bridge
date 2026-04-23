import SwiftUI

struct ContentView: View {
    @EnvironmentObject var telegramClient: TelegramClient
    @State private var messageText = ""
    @State private var selectedChat: Int = 0

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text(telegramClient.isConnected ? "🟢 Connected" : "🔴 Disconnected")
                        .foregroundColor(telegramClient.isConnected ? .green : .red)
                    Spacer()
                    Button(action: {
                        if telegramClient.isConnected {
                            telegramClient.disconnect()
                        } else {
                            telegramClient.connect()
                        }
                    }) {
                        Text(telegramClient.isConnected ? "Disconnect" : "Connect")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(telegramClient.isConnected ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }
                .padding()

                if !telegramClient.messages.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(telegramClient.messages) { msg in
                                MessageBubble(message: msg)
                            }
                        }
                        .padding()
                    }
                } else {
                    VStack {
                        Image(systemName: "message.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No messages yet")
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                }

                Divider()

                HStack {
                    TextField("Type message...", text: $messageText)
                        .textFieldStyle(.roundedBorder)
                    Button(action: {
                        if !messageText.isEmpty {
                            telegramClient.sendMessage(text: messageText, chatId: selectedChat)
                            messageText = ""
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Telegram Bridge")
            .onAppear {
                telegramClient.connect()
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.source == .local {
                Spacer()
            }

            VStack(alignment: .leading) {
                Text(message.text)
                    .padding(10)
                    .background(message.source == .local ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            if message.source != .local {
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .environmentObject(TelegramClient())
}
