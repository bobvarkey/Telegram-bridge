import Foundation

@MainActor
final class MessageListViewModel: ObservableObject {
    @Published private(set) var messages: [BridgeMessage] = []
    @Published var filter = BridgeFilter()

    private let bridgeService: BridgeService

    init(bridgeService: BridgeService) {
        self.bridgeService = bridgeService
    }

    func loadMessages() async {
        do {
            messages = try await bridgeService.fetchMessages(filter: filter)
        } catch {
            messages = []
        }
    }
}
