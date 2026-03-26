import Foundation
import SQLite

struct PackingList: Identifiable, Equatable, Codable {
    let id: Int64
    var tripId: Int64?
    var name: String
    var items: [PackingItem]
    var isTemplate: Bool
    var createdAt: Date

    var totalItems: Int { items.count }
    var checkedItems: Int { items.filter { $0.isChecked }.count }
    var progress: Double {
        guard totalItems > 0 else { return 0 }
        return Double(checkedItems) / Double(totalItems)
    }

    static func == (lhs: PackingList, rhs: PackingList) -> Bool {
        lhs.id == rhs.id
    }
}

struct PackingItem: Identifiable, Equatable, Codable {
    var id: UUID
    var name: String
    var category: PackingCategory
    var isChecked: Bool
    var note: String?
    var quantity: Int

    init(id: UUID = UUID(), name: String, category: PackingCategory, isChecked: Bool = false, note: String? = nil, quantity: Int = 1) {
        self.id = id
        self.name = name
        self.category = category
        self.isChecked = isChecked
        self.note = note
        self.quantity = quantity
    }
}

enum PackingCategory: String, Codable, CaseIterable {
    case clothing = "clothing"
    case toiletries = "toiletries"
    case electronics = "electronics"
    case documents = "documents"
    case health = "health"
    case misc = "misc"

    var displayName: String {
        switch self {
        case .clothing: return "Clothing"
        case .toiletries: return "Toiletries"
        case .electronics: return "Electronics"
        case .documents: return "Documents"
        case .health: return "Health"
        case .misc: return "Misc"
        }
    }

    var systemIcon: String {
        switch self {
        case .clothing: return "tshirt"
        case .toiletries: return "drop"
        case .electronics: return "laptopcomputer"
        case .documents: return "doc.text"
        case .health: return "cross.case"
        case .misc: return "shippingbox"
        }
    }

    var sortOrder: Int {
        switch self {
        case .clothing: return 0
        case .toiletries: return 1
        case .electronics: return 2
        case .documents: return 3
        case .health: return 4
        case .misc: return 5
        }
    }
}

extension PackingList {
    static func defaultList(for tripName: String? = nil) -> PackingList {
        PackingList(
            id: 0,
            tripId: nil,
            name: tripName ?? "Packing List",
            items: defaultItems,
            isTemplate: false,
            createdAt: Date()
        )
    }

    static func templateList(name: String) -> PackingList {
        PackingList(
            id: 0,
            tripId: nil,
            name: name,
            items: defaultItems,
            isTemplate: true,
            createdAt: Date()
        )
    }

    static var defaultItems: [PackingItem] {
        [
            // Clothing
            PackingItem(name: "T-shirts", category: .clothing, quantity: 5),
            PackingItem(name: "Underwear", category: .clothing, quantity: 7),
            PackingItem(name: "Socks", category: .clothing, quantity: 7),
            PackingItem(name: "Pants/Jeans", category: .clothing, quantity: 2),
            PackingItem(name: "Shorts", category: .clothing, quantity: 2),
            PackingItem(name: "Jacket", category: .clothing),
            PackingItem(name: "Sleepwear", category: .clothing),
            PackingItem(name: "Comfortable shoes", category: .clothing),
            // Toiletries
            PackingItem(name: "Toothbrush", category: .toiletries),
            PackingItem(name: "Toothpaste", category: .toiletries),
            PackingItem(name: "Deodorant", category: .toiletries),
            PackingItem(name: "Shampoo", category: .toiletries),
            PackingItem(name: "Sunscreen", category: .toiletries),
            // Electronics
            PackingItem(name: "Phone charger", category: .electronics),
            PackingItem(name: "Power bank", category: .electronics),
            PackingItem(name: "Headphones", category: .electronics),
            PackingItem(name: "Travel adapter", category: .electronics),
            // Documents
            PackingItem(name: "Passport/ID", category: .documents),
            PackingItem(name: "Travel insurance docs", category: .documents),
            PackingItem(name: "Flight tickets", category: .documents),
            PackingItem(name: "Hotel confirmation", category: .documents),
            // Health
            PackingItem(name: "Prescription meds", category: .health),
            PackingItem(name: "Pain reliever", category: .health),
            PackingItem(name: "First aid kit", category: .health),
            // Misc
            PackingItem(name: "Day bag/backpack", category: .misc),
            PackingItem(name: "Reusable water bottle", category: .misc),
            PackingItem(name: "Snacks for travel", category: .misc),
        ]
    }

    static var essentialsTemplate: [PackingItem] {
        [
            PackingItem(name: "Passport/ID", category: .documents),
            PackingItem(name: "Wallet", category: .documents),
            PackingItem(name: "Phone charger", category: .electronics),
            PackingItem(name: "Headphones", category: .electronics),
            PackingItem(name: "Toothbrush", category: .toiletries),
            PackingItem(name: "Deodorant", category: .toiletries),
            PackingItem(name: "Underwear", category: .clothing),
            PackingItem(name: "Socks", category: .clothing),
            PackingItem(name: "Comfortable shoes", category: .clothing),
        ]
    }
}
