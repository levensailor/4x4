import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var repository: ContentRepository

    var body: some View {
        Group {
            if let bundle = repository.bundle {
                SheetListView(bundle: bundle)
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text(repository.statusMessage)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .task {
            await repository.load()
        }
    }
}
