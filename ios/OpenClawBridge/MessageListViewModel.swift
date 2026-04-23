import Foundation

@MainActor
final class MessageListViewModel: ObservableObject {
    @Published private(set) var messages: [BridgeMessage] = []
    @Published var filter = BridgeFilter()
    @Published var isConnected = false
    @Published var errorMessage: String?

    private let bridgeService: BridgeService

    init(bridgeService: BridgeService) {
        self.bridgeService = bridgeService
        startConnection()
    }

    private func startConnection() {
        Task {
            await bridgeService.connect { [weak self] messages in
                self?.messages = messages
            }
            isConnected = true
        }
    }

    func loadMessages() async {
        do {
            messages = try await bridgeService.fetchMessages(filter: filter)
        } catch {
            errorMessage = error.localizedDescription
            messages = []
        }
    }

    func sendMessage(_ text: String) async {
        do {
            try await bridgeService.sendMessage(text)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    deinit {
        Task { @MainActor in
            bridgeService.disconnect()
        }
    }
}
