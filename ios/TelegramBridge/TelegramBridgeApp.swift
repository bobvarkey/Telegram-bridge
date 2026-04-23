import SwiftUI

@main
struct TelegramBridgeApp: App {
    @StateObject private var telegramClient = TelegramClient()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(telegramClient)
        }
    }
}
