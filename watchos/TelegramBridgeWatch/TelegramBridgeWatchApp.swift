import SwiftUI

@main
struct TelegramBridgeWatchApp: App {
    @StateObject private var watchClient = WatchClient()

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(watchClient)
        }
    }
}
