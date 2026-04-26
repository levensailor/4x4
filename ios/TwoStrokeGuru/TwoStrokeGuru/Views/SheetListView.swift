import SwiftUI

struct SheetListView: View {
    @EnvironmentObject private var repository: ContentRepository
    let bundle: ContentBundle
    @State private var selectedSheetID: CheatSheet.ID?

    private var selectedSheet: CheatSheet? {
        guard let selectedSheetID else { return nil }
        return bundle.cheatSheets.first { $0.id == selectedSheetID }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSheetID) {
                Button {
                    selectedSheetID = nil
                } label: {
                    HStack(spacing: 10) {
                        LogoMark(size: 34)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(AppBrand.name)
                                .font(.headline)
                            Text("Home")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                ForEach(ChapterCategory.allCases) { category in
                    let sheets = sheets(for: category)
                    if !sheets.isEmpty {
                        Section(category.title) {
                            if category == .diagnostics {
                                PriorityChapterGrid(
                                    sheets: sheets,
                                    navItems: bundle.navItems,
                                    selectedSheetID: $selectedSheetID
                                )
                                .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                .listRowBackground(Color.clear)
                            } else {
                                ForEach(sheets) { sheet in
                                    NavigationLink(value: sheet.id) {
                                        Label {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(bundle.navItems.first { $0.id == sheet.id }?.label ?? sheet.header.title)
                                                    .font(.headline)
                                                Text(sheet.header.subtitle)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        } icon: {
                                            Text(sheet.header.icon)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(repository.statusMessage)
                        Text("Content version \(bundle.contentVersion)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } header: {
                    Text("Content")
                }
            }
            .navigationTitle(AppBrand.name)
            .toolbar {
                Button("Refresh") {
                    Task { await repository.refresh() }
                }
                .disabled(repository.isRefreshing)
            }
        } detail: {
            if let selectedSheet {
                SheetDetailView(sheet: selectedSheet, sheets: bundle.cheatSheets, selectedSheetID: $selectedSheetID)
            } else {
                HomeView(bundle: bundle, selectedSheetID: $selectedSheetID)
            }
        }
    }

    private func sheets(for category: ChapterCategory) -> [CheatSheet] {
        let ids = category.sheetIDs
        return ids.compactMap { id in
            bundle.cheatSheets.first { $0.id == id }
        }
    }
}

private struct PriorityChapterGrid: View {
    let sheets: [CheatSheet]
    let navItems: [ContentNavItem]
    @Binding var selectedSheetID: CheatSheet.ID?

    private let columns = Array(
        repeating: GridItem(.flexible(minimum: 62), spacing: 6),
        count: 4
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(sheets) { sheet in
                Button {
                    selectedSheetID = sheet.id
                } label: {
                    VStack(spacing: 5) {
                        Text(sheet.header.icon)
                            .font(.title2)
                        Text(navItems.first { $0.id == sheet.id }?.label ?? sheet.header.title)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.68)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundStyle(selectedSheetID == sheet.id ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 76)
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selectedSheetID == sheet.id ? Color.accentColor : Color.white)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selectedSheetID == sheet.id ? Color.accentColor : Color.secondary.opacity(0.18))
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(navItems.first { $0.id == sheet.id }?.label ?? sheet.header.title)
            }
        }
    }
}

private enum ChapterCategory: String, CaseIterable, Identifiable {
    case fundamentals
    case diagnostics
    case fuelAndAir
    case topEnd
    case reference

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fundamentals: return "Fundamentals"
        case .diagnostics: return "Diagnostics"
        case .fuelAndAir: return "Fuel and Air"
        case .topEnd: return "Top End"
        case .reference: return "Reference"
        }
    }

    var icon: String {
        switch self {
        case .fundamentals: return "🧰"
        case .diagnostics: return "🔎"
        case .fuelAndAir: return "⛽"
        case .topEnd: return "🔧"
        case .reference: return "📚"
        }
    }

    var subtitle: String {
        switch self {
        case .fundamentals: return "Safety, cycle theory, and shop workflow."
        case .diagnostics: return "No-starts, plug clues, heat, and failure patterns."
        case .fuelAndAir: return "Premix, carburetors, reeds, and air leaks."
        case .topEnd: return "Compression, piston, rings, exhaust, and power valves."
        case .reference: return "Maintenance, measurements, and research sources."
        }
    }

    var sheetIDs: [String] {
        switch self {
        case .fundamentals:
            return ["safety-workflow", "two-stroke-cycle"]
        case .diagnostics:
            return ["no-start-triage", "spark-plug-reading", "overheating-seizure"]
        case .fuelAndAir:
            return ["fuel-oil-mix", "carburetor-service", "air-leaks-reeds"]
        case .topEnd:
            return ["compression-testing", "top-end-rebuild", "exhaust-power-valve"]
        case .reference:
            return ["maintenance-storage", "tools-torque", "sources-reference"]
        }
    }
}

private struct HomeView: View {
    let bundle: ContentBundle
    @Binding var selectedSheetID: CheatSheet.ID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                categoryGrid
                gettingStarted
            }
            .padding()
        }
        .navigationTitle(AppBrand.name)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            LogoMark(size: 76)
            Text(AppBrand.name)
                .font(.title.bold())
                .foregroundStyle(.secondary)
            Text(AppBrand.headline)
                .font(.largeTitle.bold())
            Text(AppBrand.valueProposition)
                .font(.headline)
                .foregroundStyle(.secondary)

            Button {
                selectedSheetID = AppBrand.startChapterID
            } label: {
                Label("Start Diagnosis", systemImage: "stethoscope")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.22), .green.opacity(0.16), .purple.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24)
        )
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
            ForEach(ChapterCategory.allCases) { category in
                categoryCard(category)
            }
        }
    }

    private func categoryCard(_ category: ChapterCategory) -> some View {
        Button {
            selectedSheetID = category.sheetIDs.first
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(category.icon)
                    .font(.largeTitle)
                Text(category.title)
                    .font(.title3.bold())
                Text(category.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(chapterCount(for: category)) chapters")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.quaternary)
            }
        }
        .buttonStyle(.plain)
    }

    private var gettingStarted: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How to use the book")
                .font(.title2.bold())
            Label("Start with no-start triage before tuning or replacing parts.", systemImage: "1.circle.fill")
            Label("Use plug, fuel, spark, and compression chapters to collect evidence.", systemImage: "2.circle.fill")
            Label("Open fuel and air chapters before carburetor adjustments.", systemImage: "3.circle.fill")
            Label("Use top-end and reference chapters when measurements point inside the engine.", systemImage: "4.circle.fill")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private func chapterCount(for category: ChapterCategory) -> Int {
        category.sheetIDs.filter { id in
            bundle.cheatSheets.contains { $0.id == id }
        }.count
    }
}

private struct LogoMark: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple, .green],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(spacing: size * 0.02) {
                Text(AppBrand.shortMark)
                    .font(.system(size: size * 0.34, weight: .black, design: .rounded))
                Text(AppBrand.markSubtitle)
                    .font(.system(size: size * 0.15, weight: .heavy, design: .rounded))
                    .tracking(size * 0.012)
            }
            .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: .blue.opacity(0.18), radius: size * 0.12, y: size * 0.06)
        .accessibilityLabel("\(AppBrand.name) logo")
    }
}
