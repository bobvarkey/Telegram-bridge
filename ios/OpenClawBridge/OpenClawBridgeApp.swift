import SwiftUI

@main
struct OpenClawBridgeApp: App {
    @StateObject private var viewModel = MessageListViewModel(
        bridgeService: MockBridgeService()
    )

    var body: some Scene {
        WindowGroup {
            MessageListView(viewModel: viewModel)
        }
    }
}
