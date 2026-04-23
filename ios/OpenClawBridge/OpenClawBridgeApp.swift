import SwiftUI

@main
struct OpenClawBridgeApp: App {
    @State private var isSetupComplete = false
    @State private var bridgeService: (any BridgeService)? = nil
    @State private var viewModel: MessageListViewModel? = nil

    var body: some Scene {
        WindowGroup {
            if isSetupComplete, let viewModel {
                MessageListView(viewModel: viewModel)
            } else {
                SetupView { botToken, backendURL, relaySecret in
                    let service = BridgeServiceImpl(
                        backendURL: backendURL,
                        relayToken: relaySecret,
                        chatID: 0
                    )
                    bridgeService = service
                    self.viewModel = MessageListViewModel(bridgeService: service)
                    isSetupComplete = true
                }
            }
        }
    }
}
