import Foundation

struct ContentManifest: Codable {
    let schemaVersion: Int
    let contentVersion: String
    let generatedAt: String
    let minAppVersion: String
    let bundle: ManifestBundle
}

struct ManifestBundle: Codable {
    let url: String
    let sha256: String
    let bytes: Int
}

struct ContentBundle: Codable {
    let schemaVersion: Int
    let contentVersion: String
    let generatedAt: String
    let minAppVersion: String
    let navItems: [ContentNavItem]
    let cheatSheets: [CheatSheet]
}

struct ContentNavItem: Codable, Identifiable {
    let id: String
    let href: String
    let label: String
    let title: String
    let icon: String
}

struct CheatSheet: Codable, Identifiable {
    let id: String
    let category: String?
    let header: SheetHeader
    let summary: String
    let sections: [SheetSection]
}

struct SheetHeader: Codable {
    let title: String
    let subtitle: String
    let icon: String
    let accent: String
    let graphics: [HeaderGraphic]?
}

struct HeaderGraphic: Codable, Identifiable {
    var id: String { "\(symbol)-\(title)" }
    let symbol: String
    let title: String
    let caption: String
}

struct ChainStep: Codable, Identifiable {
    var id: String { "\(name)-\(goal)" }
    let name: String
    let goal: String
}

struct CardItem: Codable, Identifiable {
    var id: String { title }
    let title: String
    let items: [CardLineItem]
}

enum CardLineItem: Codable, Identifiable {
    case text(String)
    case rich(RichCardLineItem)

    var id: String {
        switch self {
        case .text(let value):
            return value
        case .rich(let value):
            return value.text
        }
    }

    var displayText: String {
        switch self {
        case .text(let value):
            return value
        case .rich(let value):
            return value.text
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .text(value)
            return
        }
        self = .rich(try container.decode(RichCardLineItem.self))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .text(let value):
            try container.encode(value)
        case .rich(let value):
            try container.encode(value)
        }
    }
}

struct RichCardLineItem: Codable {
    let text: String
    let imageSrc: String?
    let imageAlt: String?
    let imagePosition: String?
}

struct SheetTable: Codable {
    let columns: [String]
    let rows: [[String]]
    let layout: String?
}

struct PluginChooserEntry: Codable, Identifiable {
    var id: String { name }
    let name: String
    let type: String
    let popularity: Int
    let emulation: String
    let bestOn: String
    let knownFor: String
}

enum SheetSection: Codable, Identifiable {
    case chain(ChainSection)
    case cards(CardsSection)
    case table(TableSection)
    case checklist(ChecklistSection)
    case image(ImageSection)
    case pluginChooser(PluginChooserSection)
    case unknown(UnknownSection)

    var id: String { "\(type)-\(title)" }

    var title: String {
        switch self {
        case .chain(let section): return section.title
        case .cards(let section): return section.title
        case .table(let section): return section.title
        case .checklist(let section): return section.title
        case .image(let section): return section.title
        case .pluginChooser(let section): return section.title
        case .unknown(let section): return section.title
        }
    }

    var type: String {
        switch self {
        case .chain: return "chain"
        case .cards: return "cards"
        case .table: return "table"
        case .checklist: return "checklist"
        case .image: return "image"
        case .pluginChooser: return "plugin-chooser"
        case .unknown(let section): return section.type
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "chain":
            self = .chain(try ChainSection(from: decoder))
        case "cards":
            self = .cards(try CardsSection(from: decoder))
        case "table":
            self = .table(try TableSection(from: decoder))
        case "checklist":
            self = .checklist(try ChecklistSection(from: decoder))
        case "image":
            self = .image(try ImageSection(from: decoder))
        case "plugin-chooser":
            self = .pluginChooser(try PluginChooserSection(from: decoder))
        default:
            self = .unknown(try UnknownSection(from: decoder))
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .chain(let section): try section.encode(to: encoder)
        case .cards(let section): try section.encode(to: encoder)
        case .table(let section): try section.encode(to: encoder)
        case .checklist(let section): try section.encode(to: encoder)
        case .image(let section): try section.encode(to: encoder)
        case .pluginChooser(let section): try section.encode(to: encoder)
        case .unknown(let section): try section.encode(to: encoder)
        }
    }
}

struct ChainSection: Codable {
    let type: String
    let title: String
    let steps: [ChainStep]
}

struct CardsSection: Codable {
    let type: String
    let title: String
    let cards: [CardItem]
    let columns: Int?
}

struct TableSection: Codable {
    let type: String
    let title: String
    let table: SheetTable
}

struct ChecklistSection: Codable {
    let type: String
    let title: String
    let items: [String]
}

struct ImageSection: Codable {
    let type: String
    let title: String
    let src: String
    let alt: String
    let caption: String?
}

struct PluginChooserSection: Codable {
    let type: String
    let title: String
    let entries: [PluginChooserEntry]
}

struct UnknownSection: Codable {
    let type: String
    let title: String
}
