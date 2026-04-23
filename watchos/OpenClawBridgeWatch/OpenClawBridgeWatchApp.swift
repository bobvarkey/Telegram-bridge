import SwiftUI

@main
struct OpenClawBridgeWatchApp: App {
    @StateObject private var viewModel = WatchMessageViewModel(
        backendURL: "https://api.telegram-bridge.com",
        relayToken: "YOUR_RELAY_TOKEN"
    )

    var body: some Scene {
        WindowGroup {
            WatchMessageListView(viewModel: viewModel)
        }
    }
}
