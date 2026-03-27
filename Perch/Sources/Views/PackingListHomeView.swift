import SwiftUI

struct PackingListHomeView: View {
    @EnvironmentObject var packingListStore: PackingListStore
    @EnvironmentObject var tripStore: TripStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewList = false
    @State private var selectedList: PackingList?
    @State private var newListName = ""
    @State private var newListTripId: Int64?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if packingListStore.lists.isEmpty && packingListStore.templates.isEmpty {
                    emptyState
                } else {
                    listContent
                }
            }
            .navigationTitle("Packing Lists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.terracotta)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewList = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Theme.terracotta)
                    }
                }
            }
            .sheet(isPresented: $showingNewList) {
                NewPackingListSheet()
            }
            .sheet(item: $selectedList) { list in
                PackingListView(packingList: list)
            }
        }
    }

    private var listContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Quick-start: from a trip
                if !tripStore.trips.filter({ !$0.isActive }).isEmpty || tripStore.activeTrip != nil {
                    quickStartSection
                }

                // Active lists
                if !packingListStore.lists.isEmpty {
                    listsSection
                }

                // Templates
                if !packingListStore.templates.isEmpty {
                    templatesSection
                }

                Spacer(minLength: 40)
            }
            .padding(16)
        }
    }

    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start from a Trip")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            // Active trip
            if let active = tripStore.activeTrip {
                Button {
                    createListForTrip(active)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "airplane.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.terracotta)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(active.name.isEmpty ? "Active Trip" : active.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                            Text("Create packing list for this trip")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "plus.circle")
                            .foregroundColor(Theme.terracotta)
                    }
                    .padding(14)
                    .background(Theme.terracotta.opacity(0.1))
                    .cornerRadius(Theme.cornerRadiusMedium)
                }
                .accessibilityLabel("Create packing list for active trip")
            }

            // Past trips
            if !pastTripsWithoutLists.isEmpty {
                ForEach(pastTripsWithoutLists.prefix(3)) { trip in
                    Button {
                        createListForTrip(trip)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle")
                                .font(.system(size: 20))
                                .foregroundColor(Theme.textSecondary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(tripPrimaryLabel(trip))
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Theme.textPrimary)
                                Text("Create list for past trip")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "plus.circle")
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding(14)
                        .background(Theme.surface)
                        .cornerRadius(Theme.cornerRadiusMedium)
                    }
                }
            }

            // Blank list
            Button {
                showingNewList = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "plus.square.dashed")
                        .font(.system(size: 20))
                        .foregroundColor(Theme.terracotta)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Blank Packing List")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                        Text("Start from scratch")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "plus.circle")
                        .foregroundColor(Theme.terracotta)
                }
                .padding(14)
                .background(Theme.surface)
                .cornerRadius(Theme.cornerRadiusMedium)
            }
        }
    }

    private var listsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Lists")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1)

                Spacer()

                Text("\(packingListStore.lists.count)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Theme.textSecondary)
            }

            ForEach(packingListStore.lists) { list in
                PackingListCard(list: list) {
                    selectedList = list
                } onDelete: {
                    packingListStore.deleteList(list)
                }
            }
        }
    }

    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Templates")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1)

                Spacer()
            }

            Text("Reusable templates you can apply to any trip.")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)

            ForEach(packingListStore.templates) { template in
                PackingTemplateCard(template: template) {
                    packingListStore.createFromTemplate(template)
                } onDelete: {
                    packingListStore.deleteTemplate(template)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "bag")
                .font(.system(size: 56))
                .foregroundColor(Theme.textSecondary.opacity(0.4))

            VStack(spacing: 6) {
                Text("No Packing Lists")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Create packing lists to make sure you never forget anything when you travel.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 12) {
                Button {
                    showingNewList = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Create Packing List")
                    }
                }
                .buttonStyle(PerchButtonStyle())

                Button {
                    let defaultList = PackingList.defaultList()
                    packingListStore.createList(name: defaultList.name, items: defaultList.items)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                        Text("Start with Defaults")
                    }
                }
                .font(.system(size: 14))
                .foregroundColor(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var pastTripsWithoutLists: [Trip] {
        tripStore.trips
            .filter { !$0.isActive }
            .filter { trip in
                !packingListStore.lists.contains { $0.tripId == trip.id }
            }
    }

    private func tripPrimaryLabel(_ trip: Trip) -> String {
        trip.cities.first ?? trip.name
    }

    private func createListForTrip(_ trip: Trip) {
        if packingListStore.list(forTripId: trip.id) != nil {
            // Already has a list, just open it
            if let list = packingListStore.list(forTripId: trip.id) {
                selectedList = list
            }
            return
        }
        let listName = tripPrimaryLabel(trip)
        if let list = packingListStore.createList(name: "Packing — \(listName)", tripId: trip.id, items: nil) {
            selectedList = list
        }
    }
}

// MARK: - Packing List Card

struct PackingListCard: View {
    let list: PackingList
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var showingDeleteAlert = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Progress ring
                ZStack {
                    Circle()
                        .stroke(Theme.surfaceElevated, lineWidth: 3)
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: list.progress)
                        .stroke(list.progress == 1 ? Theme.sage : Theme.terracotta, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))

                    if list.progress == 1 {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Theme.sage)
                    } else {
                        Text("\(Int(list.progress * 100))%")
                            .font(.caption2)
                            .foregroundColor(Theme.textSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(list.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(1)

                    Text("\(list.checkedItems)/\(list.totalItems) items packed")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(14)
            .background(Theme.surface)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
        .contextMenu {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete List?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Delete \"\(list.name)\"? This cannot be undone.")
        }
    }
}

// MARK: - Packing Template Card

struct PackingTemplateCard: View {
    let template: PackingList
    let onUse: () -> Void
    let onDelete: () -> Void

    @State private var showingDeleteAlert = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.terracotta.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.terracotta)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(template.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(1)

                    Text("\(template.totalItems) items")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                Button {
                    onUse()
                } label: {
                    Text("Use")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.terracotta)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Theme.terracotta.opacity(0.15))
                        .cornerRadius(Theme.cornerRadiusSmall)
                }
                .accessibilityLabel("Use template \(template.name)")
            }
            .padding(14)
        }
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusMedium)
        .contextMenu {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete Template", systemImage: "trash")
            }
        }
        .alert("Delete Template?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
    }
}

// MARK: - New Packing List Sheet

struct NewPackingListSheet: View {
    @EnvironmentObject var packingListStore: PackingListStore
    @EnvironmentObject var tripStore: TripStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedTripId: Int64?
    @State private var useTemplate = false
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // List name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("List Name")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        TextField("e.g. Japan Trip Packing", text: $name)
                            .font(.system(size: 16))
                            .foregroundColor(Theme.textPrimary)
                            .padding(12)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(Theme.cornerRadiusSmall)
                            .focused($isNameFocused)
                    }

                    // Link to trip
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Link to Trip (optional)")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        ForEach(tripStore.trips.filter { !$0.isActive || $0.isActive }) { trip in
                            Button {
                                selectedTripId = selectedTripId == trip.id ? nil : trip.id
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: selectedTripId == trip.id ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(selectedTripId == trip.id ? Theme.terracotta : Theme.textSecondary)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(tripPrimaryLabel(trip))
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Theme.textPrimary)
                                        Text(trip.isActive ? "Active" : "Completed")
                                            .font(.system(size: 12))
                                            .foregroundColor(Theme.textSecondary)
                                    }

                                    Spacer()
                                }
                                .padding(12)
                                .background(selectedTripId == trip.id ? Theme.terracotta.opacity(0.08) : Theme.surfaceElevated)
                                .cornerRadius(Theme.cornerRadiusSmall)
                            }
                        }

                        if tripStore.trips.isEmpty {
                            Text("No trips yet. Complete a trip first to link it here.")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(Theme.surfaceElevated)
                                .cornerRadius(Theme.cornerRadiusSmall)
                        }
                    }

                    // Templates
                    if !packingListStore.templates.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Or start from a template")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)

                            ForEach(packingListStore.templates.prefix(3)) { template in
                                Button {
                                    packingListStore.createFromTemplate(template, tripId: selectedTripId, newName: name.isEmpty ? nil : name)
                                    dismiss()
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "doc.on.doc")
                                            .font(.system(size: 14))
                                            .foregroundColor(Theme.terracotta)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(template.name)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Theme.textPrimary)
                                            Text("\(template.totalItems) items")
                                                .font(.system(size: 12))
                                                .foregroundColor(Theme.textSecondary)
                                        }

                                        Spacer()

                                        Image(systemName: "arrow.right.circle")
                                            .font(.system(size: 14))
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                    .padding(12)
                                    .background(Theme.surfaceElevated)
                                    .cornerRadius(Theme.cornerRadiusSmall)
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("New Packing List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        createList()
                    } label: {
                        Text("Create")
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
        .presentationDetents([.medium, .large])
    }

    private func tripPrimaryLabel(_ trip: Trip) -> String {
        trip.cities.first ?? trip.name
    }

    private func createList() {
        guard !name.isEmpty else { return }
        let items = PackingList.defaultList(for: nil).items
        packingListStore.createList(name: name, tripId: selectedTripId, items: items)
        dismiss()
    }
}
