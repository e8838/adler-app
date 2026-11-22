import SwiftUI

@main
struct AdlerAppApp: App {
    @StateObject private var store = TransactionStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
