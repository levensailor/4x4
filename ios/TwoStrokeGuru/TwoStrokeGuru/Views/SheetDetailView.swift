import SwiftUI

struct SheetDetailView: View {
    let sheet: CheatSheet
    let sheets: [CheatSheet]
    @Binding var selectedSheetID: CheatSheet.ID?

    private var currentIndex: Int? {
        sheets.firstIndex { $0.id == sheet.id }
    }

    private var previousSheet: CheatSheet? {
        guard let currentIndex, currentIndex > 0 else { return nil }
        return sheets[currentIndex - 1]
    }

    private var nextSheet: CheatSheet? {
        guard let currentIndex, currentIndex < sheets.count - 1 else { return nil }
        return sheets[currentIndex + 1]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                ForEach(sheet.sections) { section in
                    SectionView(section: section)
                }

                chapterPager
            }
            .padding()
        }
        .navigationTitle(sheet.header.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Text(sheet.header.icon)
                    .font(.largeTitle)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(sheet.header.title)
                        .font(.largeTitle.bold())
                    Text(sheet.header.subtitle)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }

            if !sheet.summary.isEmpty {
                Text(sheet.summary)
                    .foregroundStyle(.secondary)
            }

            if let graphics = sheet.header.graphics, !graphics.isEmpty {
                ChapterGraphicStrip(graphics: graphics)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private var chapterPager: some View {
        HStack(spacing: 12) {
            if let previousSheet {
                Button {
                    selectedSheetID = previousSheet.id
                } label: {
                    pagerCard(label: "Previous", sheet: previousSheet)
                }
                .buttonStyle(.plain)
            }
            if let nextSheet {
                Button {
                    selectedSheetID = nextSheet.id
                } label: {
                    pagerCard(label: "Next", sheet: nextSheet)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func pagerCard(label: String, sheet: CheatSheet) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text("\(sheet.header.icon) \(sheet.header.title)")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.quaternary)
        }
    }
}

private struct ChapterGraphicStrip: View {
    let graphics: [HeaderGraphic]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
            ForEach(graphics) { graphic in
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: graphic.symbol)
                        .font(.title2.bold())
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 42, height: 42)
                        .background(.background, in: RoundedRectangle(cornerRadius: 12))
                        .accessibilityHidden(true)

                    Text(graphic.title)
                        .font(.headline)
                    Text(graphic.caption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.background.opacity(0.72), in: RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.quaternary)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}
