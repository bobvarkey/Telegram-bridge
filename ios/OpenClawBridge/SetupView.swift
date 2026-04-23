import SwiftUI

struct SetupView: View {
    @State private var botToken = ""
    @State private var backendURL = "https://api.telegram-bridge.com"
    @State private var relaySecret = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var setupComplete = false

    let onSetupComplete: (String, String, String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Telegram Bot Configuration") {
                    SecureField("Bot Token", text: $botToken)
                        .textInputAutocapitalization(.never)

                    TextField("Backend URL", text: $backendURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)

                    SecureField("Relay Secret", text: $relaySecret)
                        .textInputAutocapitalization(.never)
                }

                Section("Instructions") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Create a bot via @BotFather on Telegram")
                            .font(.caption)
                        Text("2. Copy the bot token above")
                            .font(.caption)
                        Text("3. Enter your backend URL")
                            .font(.caption)
                        Text("4. Tap 'Setup Webhook' to register")
                            .font(.caption)
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Button(action: setupWebhook) {
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Setting up...")
                            }
                        } else {
                            Text("Setup Webhook")
                        }
                    }
                    .disabled(botToken.isEmpty || backendURL.isEmpty || relaySecret.isEmpty || isLoading)
                }
            }
            .navigationTitle("Telegram Bridge Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func setupWebhook() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let webhookURL = "\(backendURL)/webhook/telegram"

                guard let url = URL(string: "\(backendURL)/api/setup-webhook") else {
                    throw SetupError.invalidURL
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(relaySecret, forHTTPHeaderField: "x-relay-token")

                let payload = ["webhook_url": webhookURL]
                request.httpBody = try JSONSerialization.data(withJSONObject: payload)

                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw SetupError.invalidResponse
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw SetupError.serverError(errorText)
                }

                DispatchQueue.main.async {
                    setupComplete = true
                    onSetupComplete(botToken, backendURL, relaySecret)
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

enum SetupError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid backend URL"
        case .invalidResponse:
            return "Server returned invalid response"
        case .serverError(let msg):
            return "Setup failed: \(msg)"
        }
    }
}

#Preview {
    SetupView { _, _, _ in }
}
