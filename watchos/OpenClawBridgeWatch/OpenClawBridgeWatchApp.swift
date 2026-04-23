import SwiftUI

@main
struct OpenClawBridgeWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchMessageListView(messages: SampleWatchData.messages)
        }
    }
}
