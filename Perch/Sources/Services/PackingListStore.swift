import Foundation
import SQLite
import os.log

@MainActor
final class PackingListStore: ObservableObject {
    private var db: Connection?
    private let packingListsTable = Table("packing_lists")
    private let packingItemsTable = Table("packing_items")

    // PackingList columns
    private let listId = Expression<Int64>("id")
    private let listTripId = Expression<Int64?>("trip_id")
    private let listName = Expression<String>("name")
    private let listIsTemplate = Expression<Bool>("is_template")
    private let listCreatedAt = Expression<Date>("created_at")

    // PackingItem columns
    private let itemId = Expression<Int64>("id")
    private let itemListId = Expression<Int64>("list_id")
    private let itemUUID = Expression<String>("uuid")
    private let itemName = Expression<String>("name")
    private let itemCategory = Expression<String>("category")
    private let itemIsChecked = Expression<Bool>("is_checked")
    private let itemNote = Expression<String?>("note")
    private let itemQuantity = Expression<Int>("quantity")

    private let logger = Logger(subsystem: "com.perch.ios", category: "PackingListStore")

    @Published var lists: [PackingList] = []
    @Published var templates: [PackingList] = []

    init() {
        setupDatabase()
        loadLists()
    }

    private func setupDatabase() {
        do {
            guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
                logger.error("PackingListStore: Could not find documents directory")
                return
            }
            db = try Connection("\(path)/perch.sqlite3")
            try createTables()
            logger.info("PackingListStore: Database initialized")
        } catch {
            logger.error("PackingListStore: Setup error: \(error.localizedDescription)")
        }
    }

    private func createTables() throws {
        try db?.run(packingListsTable.create(ifNotExists: true) { t in
            t.column(listId, primaryKey: .autoincrement)
            t.column(listTripId)
            t.column(listName)
            t.column(listIsTemplate, defaultValue: false)
            t.column(listCreatedAt)
        })

        try db?.run(packingItemsTable.create(ifNotExists: true) { t in
            t.column(itemId, primaryKey: .autoincrement)
            t.column(itemListId)
            t.column(itemUUID)
            t.column(itemName)
            t.column(itemCategory)
            t.column(itemIsChecked, defaultValue: false)
            t.column(itemNote)
            t.column(itemQuantity, defaultValue: 1)
        })
    }

    private func loadLists() {
        guard let db = db else { return }
        do {
            var loadedLists: [PackingList] = []
            for row in try db.prepare(packingListsTable.order(listCreatedAt.desc)) {
                let id = row[listId]
                let items = loadItems(forListId: id)
                let list = PackingList(
                    id: id,
                    tripId: row[listTripId],
                    name: row[listName],
                    items: items,
                    isTemplate: row[listIsTemplate],
                    createdAt: row[listCreatedAt]
                )
                loadedLists.append(list)
            }
            lists = loadedLists.filter { !$0.isTemplate }
            templates = loadedLists.filter { $0.isTemplate }
            logger.info("PackingListStore: Loaded \(self.lists.count) lists, \(self.templates.count) templates")
        } catch {
            logger.error("PackingListStore: Load error: \(error.localizedDescription)")
        }
    }

    private func loadItems(forListId listIdValue: Int64) -> [PackingItem] {
        guard let db = db else { return [] }
        var items: [PackingItem] = []
        do {
            let query = packingItemsTable.filter(itemListId == listIdValue)
            for row in try db.prepare(query) {
                guard let category = PackingCategory(rawValue: row[itemCategory]) else { continue }
                let item = PackingItem(
                    id: UUID(uuidString: row[itemUUID]) ?? UUID(),
                    name: row[itemName],
                    category: category,
                    isChecked: row[itemIsChecked],
                    note: row[itemNote],
                    quantity: row[itemQuantity]
                )
                items.append(item)
            }
        } catch {
            logger.error("PackingListStore: Load items error: \(error.localizedDescription)")
        }
        return items
    }

    // MARK: - Create

    @discardableResult
    func createList(name: String, tripId: Int64? = nil, items: [PackingItem]? = nil) -> PackingList? {
        guard let db = db else { return nil }
        do {
            let theItems = items ?? PackingList.defaultItems
            let insert = packingListsTable.insert(
                listTripId <- tripId,
                listName <- name,
                listIsTemplate <- false,
                listCreatedAt <- Date()
            )
            let newId = try db.run(insert)

            for var item in theItems {
                let uuidStr = item.id.uuidString
                try db.run(packingItemsTable.insert(
                    itemListId <- newId,
                    itemUUID <- uuidStr,
                    itemName <- item.name,
                    itemCategory <- item.category.rawValue,
                    itemIsChecked <- item.isChecked,
                    itemNote <- item.note,
                    itemQuantity <- item.quantity
                ))
            }

            let list = PackingList(
                id: newId,
                tripId: tripId,
                name: name,
                items: theItems,
                isTemplate: false,
                createdAt: Date()
            )
            lists.insert(list, at: 0)
            logger.info("PackingListStore: Created list '\(name)' with \(theItems.count) items")
            return list
        } catch {
            logger.error("PackingListStore: Create error: \(error.localizedDescription)")
            return nil
        }
    }

    @discardableResult
    func createFromTemplate(_ template: PackingList, tripId: Int64? = nil, newName: String? = nil) -> PackingList? {
        createList(
            name: newName ?? template.name,
            tripId: tripId,
            items: template.items.map { item in
                PackingItem(
                    id: UUID(),
                    name: item.name,
                    category: item.category,
                    isChecked: false,
                    note: item.note,
                    quantity: item.quantity
                )
            }
        )
    }

    @discardableResult
    func createTemplate(name: String, items: [PackingItem]? = nil) -> PackingList? {
        guard let db = db else { return nil }
        do {
            let theItems = items ?? PackingList.defaultItems
            let insert = packingListsTable.insert(
                listTripId <- nil as Int64?,
                listName <- name,
                listIsTemplate <- true,
                listCreatedAt <- Date()
            )
            let newId = try db.run(insert)

            for var item in theItems {
                let uuidStr = item.id.uuidString
                try db.run(packingItemsTable.insert(
                    itemListId <- newId,
                    itemUUID <- uuidStr,
                    itemName <- item.name,
                    itemCategory <- item.category.rawValue,
                    itemIsChecked <- item.isChecked,
                    itemNote <- item.note,
                    itemQuantity <- item.quantity
                ))
            }

            let list = PackingList(
                id: newId,
                tripId: nil,
                name: name,
                items: theItems,
                isTemplate: true,
                createdAt: Date()
            )
            templates.append(list)
            logger.info("PackingListStore: Created template '\(name)'")
            return list
        } catch {
            logger.error("PackingListStore: Create template error: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Update Items

    func toggleItem(listId listIdValue: Int64, itemId: UUID) {
        guard let db = db else { return }
        let uuidStr = itemId.uuidString
        do {
            let row = packingItemsTable.filter(itemListId == listIdValue && itemUUID == uuidStr)
            if let existingRow = try db.pluck(row) {
                let currentChecked = existingRow[itemIsChecked]
                try db.run(row.update(itemIsChecked <- !currentChecked))
            }
            // Update local state
            if let idx = lists.firstIndex(where: { $0.id == listIdValue }),
               let itemIdx = lists[idx].items.firstIndex(where: { $0.id == itemId }) {
                lists[idx].items[itemIdx].isChecked.toggle()
            }
            logger.debug("PackingListStore: Toggled item \(uuidStr)")
        } catch {
            logger.error("PackingListStore: Toggle error: \(error.localizedDescription)")
        }
    }

    func addItem(listId listIdValue: Int64, name: String, category: PackingCategory, quantity: Int = 1, note: String? = nil) {
        guard let db = db else { return }
        let newId = UUID()
        let uuidStr = newId.uuidString
        do {
            try db.run(packingItemsTable.insert(
                itemListId <- listIdValue,
                itemUUID <- uuidStr,
                itemName <- name,
                itemCategory <- category.rawValue,
                itemIsChecked <- false,
                itemNote <- note,
                itemQuantity <- quantity
            ))
            let item = PackingItem(id: newId, name: name, category: category, note: note, quantity: quantity)
            if let idx = lists.firstIndex(where: { $0.id == listIdValue }) {
                lists[idx].items.append(item)
            }
            logger.info("PackingListStore: Added item '\(name)'")
        } catch {
            logger.error("PackingListStore: Add item error: \(error.localizedDescription)")
        }
    }

    func removeItem(listId listIdValue: Int64, itemId: UUID) {
        guard let db = db else { return }
        let uuidStr = itemId.uuidString
        do {
            let row = packingItemsTable.filter(itemListId == listIdValue && itemUUID == uuidStr)
            try db.run(row.delete())
            if let idx = lists.firstIndex(where: { $0.id == listIdValue }) {
                lists[idx].items.removeAll { $0.id == itemId }
            }
            logger.debug("PackingListStore: Removed item")
        } catch {
            logger.error("PackingListStore: Remove item error: \(error.localizedDescription)")
        }
    }

    func updateItemNote(listId listIdValue: Int64, itemId: UUID, note: String?) {
        guard let db = db else { return }
        let uuidStr = itemId.uuidString
        do {
            let row = packingItemsTable.filter(itemListId == listIdValue && itemUUID == uuidStr)
            try db.run(row.update(itemNote <- note))
            if let idx = lists.firstIndex(where: { $0.id == listIdValue }),
               let itemIdx = lists[idx].items.firstIndex(where: { $0.id == itemId }) {
                lists[idx].items[itemIdx].note = note
            }
        } catch {
            logger.error("PackingListStore: Update note error: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete

    func deleteList(_ list: PackingList) {
        guard let db = db else { return }
        do {
            let items = packingItemsTable.filter(itemListId == list.id)
            try db.run(items.delete())
            let row = packingListsTable.filter(listId == list.id)
            try db.run(row.delete())
            lists.removeAll { $0.id == list.id }
            templates.removeAll { $0.id == list.id }
            logger.info("PackingListStore: Deleted list '\(list.name)'")
        } catch {
            logger.error("PackingListStore: Delete error: \(error.localizedDescription)")
        }
    }

    func deleteTemplate(_ list: PackingList) {
        deleteList(list)
    }

    // MARK: - List for Trip

    func list(forTripId tripId: Int64) -> PackingList? {
        lists.first { $0.tripId == tripId }
    }

    // MARK: - Reset

    func resetList(_ list: PackingList) {
        guard let db = db else { return }
        do {
            let items = packingItemsTable.filter(itemListId == list.id)
            try db.run(items.update(itemIsChecked <- false))
            if let idx = lists.firstIndex(where: { $0.id == list.id }) {
                for i in lists[idx].items.indices {
                    lists[idx].items[i].isChecked = false
                }
            }
            logger.info("PackingListStore: Reset list '\(list.name)'")
        } catch {
            logger.error("PackingListStore: Reset error: \(error.localizedDescription)")
        }
    }
}
