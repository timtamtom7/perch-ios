import SwiftUI

struct PackingListView: View {
    let packingList: PackingList
    @EnvironmentObject var packingListStore: PackingListStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddItem = false
    @State private var showingDeleteAlert = false
    @State private var showingResetAlert = false
    @State private var newItemName = ""
    @State private var newItemCategory: PackingCategory = .misc
    @State private var newItemNote = ""
    @State private var newItemQuantity = 1
    @State private var expandedCategories: Set<PackingCategory> = Set(PackingCategory.allCases)
    @State private var editingListName = false
    @State private var listNameText: String = ""

    private var groupedItems: [(category: PackingCategory, items: [PackingItem])] {
        let grouped = Dictionary(grouping: packingList.items) { $0.category }
        return PackingCategory.allCases
            .filter { grouped[$0] != nil }
            .sorted { $0.sortOrder < $1.sortOrder }
            .map { ($0, grouped[$0]!.sorted { $0.name < $1.name }) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if packingList.items.isEmpty {
                    emptyState
                } else {
                    listContent
                }
            }
            .navigationTitle(listTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.terracotta)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingAddItem = true
                        } label: {
                            Label("Add Item", systemImage: "plus")
                        }

                        Button {
                            packingListStore.resetList(packingList)
                        } label: {
                            Label("Reset All", systemImage: "arrow.counterclockwise")
                        }

                        Divider()

                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete List", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(Theme.terracotta)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddPackingItemSheet(listId: packingList.id)
            }
            .alert("Delete Packing List?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    packingListStore.deleteList(packingList)
                    dismiss()
                }
            } message: {
                Text("This will permanently delete \"\(packingList.name)\" and all its items. This action cannot be undone.")
            }
        }
    }

    private var listTitle: String {
        packingList.name
    }

    private var listContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Progress bar
                progressHeader

                // Categories
                ForEach(groupedItems, id: \.category) { group in
                    categorySection(category: group.category, items: group.items)
                }

                // Add item button
                addItemButton

                Spacer(minLength: 80)
            }
            .padding(.horizontal, 16)
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 10) {
            HStack {
                Text("\(packingList.checkedItems) of \(packingList.totalItems) packed")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                if packingList.totalItems > 0 && packingList.checkedItems == packingList.totalItems {
                    Label("Ready to go!", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.sage)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.surfaceElevated)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(packingList.checkedItems == packingList.totalItems && packingList.totalItems > 0 ? Theme.sage : Theme.terracotta)
                        .frame(width: geometry.size.width * packingList.progress, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: packingList.progress)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 16)
    }

    private func categorySection(category: PackingCategory, items: [PackingItem]) -> some View {
        VStack(spacing: 0) {
            // Category header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if expandedCategories.contains(category) {
                        expandedCategories.remove(category)
                    } else {
                        expandedCategories.insert(category)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: category.systemIcon)
                        .font(.system(size: 14))
                        .foregroundColor(Theme.terracotta)
                        .frame(width: 20)

                    Text(category.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Text("\(items.filter { $0.isChecked }.count)/\(items.count)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.surfaceElevated)
                        .cornerRadius(4)

                    Spacer()

                    Image(systemName: expandedCategories.contains(category) ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(Theme.surface)
            }
            .accessibilityLabel("\(category.displayName), \(items.filter { $0.isChecked }.count) of \(items.count) items packed")

            if expandedCategories.contains(category) {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        PackingItemRow(
                            item: item,
                            onToggle: {
                                packingListStore.toggleItem(listId: packingList.id, itemId: item.id)
                            },
                            onDelete: {
                                packingListStore.removeItem(listId: packingList.id, itemId: item.id)
                            },
                            onUpdateNote: { note in
                                packingListStore.updateItemNote(listId: packingList.id, itemId: item.id, note: note)
                            }
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Divider()
                .background(Theme.divider)
        }
        .cornerRadius(Theme.cornerRadiusMedium)
        .padding(.bottom, 8)
    }

    private var addItemButton: some View {
        Button {
            showingAddItem = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                Text("Add item")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(Theme.terracotta)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.terracotta.opacity(0.1))
            .cornerRadius(Theme.cornerRadiusMedium)
        }
        .padding(.top, 16)
        .accessibilityLabel("Add new packing item")
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bag")
                .font(.system(size: 48))
                .foregroundColor(Theme.textSecondary.opacity(0.4))

            VStack(spacing: 6) {
                Text("No items yet")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Text("Add items to your packing list so you don't forget anything.")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                showingAddItem = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Add First Item")
                }
            }
            .buttonStyle(PerchButtonStyle())
            .frame(width: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Packing Item Row

struct PackingItemRow: View {
    let item: PackingItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onUpdateNote: (String?) -> Void

    @State private var showingNote = false
    @State private var noteText = ""
    @State private var showingDeleteConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Checkbox
                Button {
                    onToggle()
                } label: {
                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(item.isChecked ? Theme.sage : Theme.textSecondary)
                }
                .accessibilityLabel(item.isChecked ? "Uncheck \(item.name)" : "Check \(item.name)")

                // Item name and quantity
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(item.name)
                            .font(.system(size: 15))
                            .foregroundColor(item.isChecked ? Theme.textSecondary : Theme.textPrimary)
                            .strikethrough(item.isChecked, color: Theme.textSecondary)

                        if item.quantity > 1 {
                            Text("×\(item.quantity)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Theme.textSecondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(Theme.surfaceElevated)
                                .cornerRadius(4)
                        }
                    }

                    if let note = item.note, !note.isEmpty {
                        Text(note)
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Note button
                Button {
                    noteText = item.note ?? ""
                    showingNote.toggle()
                } label: {
                    Image(systemName: item.note?.isEmpty == false ? "note.text" : "note.text.badge.plus")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary.opacity(0.6))
                }
                .accessibilityLabel(item.note?.isEmpty == false ? "Edit note" : "Add note")

                // Delete
                Button {
                    showingDeleteConfirm = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary.opacity(0.5))
                        .padding(6)
                }
                .accessibilityLabel("Delete \(item.name)")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            // Note editor
            if showingNote {
                HStack(spacing: 8) {
                    TextField("Add a note…", text: $noteText)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textPrimary)
                        .padding(8)
                        .background(Theme.surfaceElevated)
                        .cornerRadius(Theme.cornerRadiusPill)

                    Button {
                        onUpdateNote(noteText.isEmpty ? nil : noteText)
                        showingNote = false
                    } label: {
                        Text("Save")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.terracotta)
                    }

                    Button {
                        showingNote = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(item.isChecked ? Theme.surface.opacity(0.5) : Theme.surface)
        .confirmationDialog("Delete Item?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

// MARK: - Add Item Sheet

struct AddPackingItemSheet: View {
    let listId: Int64
    @EnvironmentObject var packingListStore: PackingListStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var category: PackingCategory = .misc
    @State private var quantity = 1
    @State private var note = ""
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Item Name")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        TextField("e.g. Rain jacket", text: $name)
                            .font(.system(size: 16))
                            .foregroundColor(Theme.textPrimary)
                            .padding(12)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(Theme.cornerRadiusSmall)
                            .focused($isNameFocused)
                    }

                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                            ForEach(PackingCategory.allCases, id: \.self) { cat in
                                Button {
                                    category = cat
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: cat.systemIcon)
                                            .font(.system(size: 12))
                                        Text(cat.displayName)
                                            .font(.system(size: 13))
                                    }
                                    .foregroundColor(category == cat ? Theme.background : Theme.textPrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(category == cat ? Theme.terracotta : Theme.surfaceElevated)
                                    .cornerRadius(Theme.cornerRadiusSmall)
                                }
                            }
                        }
                    }

                    // Quantity
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quantity")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        HStack(spacing: 16) {
                            Button {
                                if quantity > 1 { quantity -= 1 }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(quantity > 1 ? Theme.terracotta : Theme.textSecondary.opacity(0.3))
                            }
                            .disabled(quantity <= 1)

                            Text("\(quantity)")
                                .font(.system(size: 20, weight: .semibold, design: .monospaced))
                                .foregroundColor(Theme.textPrimary)
                                .frame(width: 40)

                            Button {
                                quantity += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Theme.terracotta)
                            }
                        }
                    }

                    // Note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note (optional)")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        TextField("e.g. Full-size only, not travel size", text: $note, axis: .vertical)
                            .font(.system(size: 14))
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(2...3)
                            .padding(10)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(Theme.cornerRadiusSmall)
                    }
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addItem()
                    } label: {
                        Text("Add")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(name.isEmpty ? Theme.textSecondary : Theme.terracotta)
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
        .presentationDetents([.medium])
    }

    private func addItem() {
        guard !name.isEmpty else { return }
        packingListStore.addItem(
            listId: listId,
            name: name,
            category: category,
            quantity: quantity,
            note: note.isEmpty ? nil : note
        )
        dismiss()
    }
}
