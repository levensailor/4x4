import SwiftUI

@main
struct TwoStrokeGuruApp: App {
    @StateObject private var repository = ContentRepository()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(repository)
        }
    }
}
