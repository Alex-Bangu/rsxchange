
import Foundation

enum Game: String, Codable {
    case osrs = "oldschool"
    case rs3 = "rs"
}

struct SearchResponse: Codable {
    var results: [Item]
}

struct Item: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let icon: URL?
    let icon_large: URL?
    let type: String?
    let typeIcon: URL?
    let current: Price?
    let today: Price?
    let members: String?
    var game: Game?

    enum CodingKeys: String, CodingKey {
        case id, name, description, icon, type, members, current, today, game
        case icon_large
        case typeIcon
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encodeIfPresent(icon, forKey: .icon)
        try container.encodeIfPresent(icon_large, forKey: .icon_large)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(typeIcon, forKey: .typeIcon)
        try container.encodeIfPresent(current, forKey: .current)
        try container.encodeIfPresent(today, forKey: .today)
        try container.encodeIfPresent(members, forKey: .members)
        try container.encodeIfPresent(game, forKey: .game)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = idInt
        } else {
            let idString = try container.decode(String.self, forKey: .id)
            id = Int(idString) ?? 0
        }
        
        name = try container.decode(String.self, forKey: .name)
        description = try? container.decode(String.self, forKey: .description)
        icon = try? container.decode(URL.self, forKey: .icon)
        icon_large = try? container.decode(URL.self, forKey: .icon_large)
        type = try? container.decode(String.self, forKey: .type)
        typeIcon = try? container.decode(URL.self, forKey: .typeIcon)
        current = try? container.decode(Price.self, forKey: .current)
        today = try? container.decode(Price.self, forKey: .today)
        members = try? container.decode(String.self, forKey: .members)
        game = try? container.decode(Game.self, forKey: .game)
    }
}

struct Price: Codable, Hashable {
    let trend: String?
    let price: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trend = try? container.decode(String.self, forKey: .trend)
        if let priceInt = try? container.decode(Int.self, forKey: .price) {
            price = String(priceInt)
        } else if let priceDouble = try? container.decode(Double.self, forKey: .price) {
            price = String(priceDouble)
        } else {
            price = try container.decode(String.self, forKey: .price)
        }
    }
}

struct DetailItem: Codable {
    let item: ItemDetail
}

struct ItemDetail: Codable, Hashable {
    let icon: URL
    let icon_large: URL
    let id: Int
    let type: String
    let typeIcon: URL
    let name: String
    let description: String
    let current: Price
    let today: Price
    let members: String
    let day30: Trend
    let day90: Trend
    let day180: Trend
}

struct Trend: Codable, Hashable {
    let trend: String
    let change: String
}

struct GraphData: Codable {
    let daily: [String: Int]
    let average: [String: Int]
}

struct WikiInfo: Codable {
    let query: WikiQuery
}

struct WikiQuery: Codable {
    let pages: [String: WikiPage]
}

struct WikiPage: Codable {
    let fullurl: URL
    let extract: String?
}
