import SwiftUI

struct BirdingEventsView: View {
    @State private var selectedEventType: Event.EventType?
    @State private var selectedEvent: Event?
    @State private var showingEventDetail = false

    private var communityService: CommunityService { CommunityService.shared }

    private var filteredEvents: [Event] {
        if let type = selectedEventType {
            return communityService.getUpcomingEvents().filter { $0.eventType == type }
        }
        return communityService.getUpcomingEvents()
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            eventTypeFilters

            if filteredEvents.isEmpty {
                emptyState
            } else {
                eventsList
            }
        }
        .background(Theme.cream)
        .sheet(isPresented: $showingEventDetail) {
            if let event = selectedEvent {
                EventDetailView(event: event)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.forestGreen)

                Text("Birding Events")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()
            }

            Text("Discover local bird watching walks, workshops, and expert-led tours near you")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding()
    }

    private var eventTypeFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All Events",
                    isActive: selectedEventType == nil
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedEventType = nil
                    }
                }

                ForEach(Event.EventType.allCases, id: \.self) { type in
                    FilterChip(
                        title: type.rawValue,
                        isActive: selectedEventType == type,
                        icon: type.icon
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedEventType = type
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 12)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundStyle(Theme.textSecondary.opacity(0.4))

            Text("No Upcoming Events")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            Text("Check back soon for birding events in your area")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var eventsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Weekend highlight
                weekendHighlight

                // Event cards
                ForEach(filteredEvents) { event in
                    EventCard(event: event)
                        .onTapGesture {
                            selectedEvent = event
                            showingEventDetail = true
                        }
                }
            }
            .padding()
        }
    }

    private var weekendHighlight: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(Theme.barkBrown)
                Text("There's a birding event near you this weekend!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
            }

            if let nextWeekend = filteredEvents.first {
                HStack(spacing: 16) {
                    VStack {
                        Text(nextWeekend.startDate, format: .dateTime.day())
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Theme.forestGreen)
                        Text(nextWeekend.startDate, format: .dateTime.weekday(.abbreviated))
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .frame(width: 60)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(nextWeekend.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(2)

                        Text(nextWeekend.organizer)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary)

                        HStack(spacing: 4) {
                            Image(systemName: nextWeekend.eventType.icon)
                                .font(.system(size: 10))
                            Text(nextWeekend.eventType.rawValue)
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(Theme.barkBrown)
                    }

                    Spacer()

                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Theme.forestGreen.opacity(0.6))
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Theme.forestGreen.opacity(0.1), Theme.skyBlue.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    selectedEvent = nextWeekend
                    showingEventDetail = true
                }
            }
        }
        .padding()
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Event Card

struct EventCard: View {
    let event: Event

    private var daysUntil: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: event.startDate)
        return components.day ?? 0
    }

    private var timeUntilString: String {
        if daysUntil == 0 {
            return "Today"
        } else if daysUntil == 1 {
            return "Tomorrow"
        } else if daysUntil < 7 {
            return "In \(daysUntil) days"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: event.startDate)
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Event type icon
            ZStack {
                Circle()
                    .fill(eventTypeColor.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: event.eventType.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(eventTypeColor)
            }

            // Event info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(event.eventType.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(eventTypeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(eventTypeColor.opacity(0.1))
                        .clipShape(Capsule())

                    Spacer()

                    Text(timeUntilString)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }

                Text(event.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label(event.organizer, systemImage: "person")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)

                    Label(event.location.name, systemImage: "location")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }

                // Species highlight
                if !event.speciesHighlight.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "bird")
                            .font(.system(size: 9))
                        Text(event.speciesHighlight.prefix(3).joined(separator: ", "))
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(Theme.barkBrown)
                }
            }

            Spacer()

            // Date badge
            VStack(spacing: 2) {
                Text(event.startDate, format: .dateTime.day())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text(event.startDate, format: .dateTime.month(.abbreviated))
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(width: 40)
        }
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private var eventTypeColor: Color {
        switch event.eventType {
        case .audubonWalk: return Theme.forestGreen
        case .christmasBirdCount: return .blue
        case .photographyTour: return .purple
        case .conservationDay: return .green
        case .expertFieldTrip: return Theme.barkBrown
        case .workshop: return .orange
        case .festival: return .pink
        }
    }
}

// MARK: - Event Detail View

struct EventDetailView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header image placeholder
                    ZStack {
                        LinearGradient(
                            colors: [Theme.forestGreen.opacity(0.3), Theme.skyBlue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        Image(systemName: event.eventType.icon)
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 16) {
                        // Event type badge
                        HStack {
                            Image(systemName: event.eventType.icon)
                            Text(event.eventType.rawValue)
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(eventTypeColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(eventTypeColor.opacity(0.1))
                        .clipShape(Capsule())

                        // Title
                        Text(event.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)

                        // Organizer
                        HStack {
                            Image(systemName: "person.fill")
                            Text(event.organizer)
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)

                        Divider()

                        // Date & Time
                        VStack(alignment: .leading, spacing: 8) {
                            Label {
                                Text(event.startDate, format: .dateTime.weekday(.wide).month().day().year())
                            } icon: {
                                Image(systemName: "calendar")
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textPrimary)

                            Label {
                                Text("\(event.startDate, format: .dateTime.hour().minute()) - \(event.endDate, format: .dateTime.hour().minute())")
                            } icon: {
                                Image(systemName: "clock")
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textPrimary)
                        }

                        // Location
                        Label {
                            VStack(alignment: .leading) {
                                Text(event.location.name)
                                Text("(\(String(format: "%.2f", event.location.latitude)), \(String(format: "%.2f", event.location.longitude)))")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        } icon: {
                            Image(systemName: "location.fill")
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textPrimary)

                        Divider()

                        // Description
                        Text("About this Event")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)

                        Text(event.description)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textSecondary)
                            .lineSpacing(4)

                        // Species highlight
                        if !event.speciesHighlight.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Species You Might See")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Theme.textPrimary)

                                FlowLayout(spacing: 8) {
                                    ForEach(event.speciesHighlight, id: \.self) { species in
                                        Text(species)
                                            .font(.system(size: 12))
                                            .foregroundStyle(Theme.forestGreen)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Theme.forestGreen.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }

                        // Action buttons
                        VStack(spacing: 12) {
                            if event.registrationUrl != nil {
                                Button(action: {
                                    // Open registration URL
                                }) {
                                    HStack {
                                        Image(systemName: "safari")
                                        Text("Register for Event")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Theme.forestGreen)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }

                            Button(action: {
                                // Add to calendar
                            }) {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                    Text("Add to Calendar")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Theme.forestGreen)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Theme.forestGreen.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Theme.cream)
            .navigationTitle("Event Details")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var eventTypeColor: Color {
        switch event.eventType {
        case .audubonWalk: return Theme.forestGreen
        case .christmasBirdCount: return .blue
        case .photographyTour: return .purple
        case .conservationDay: return .green
        case .expertFieldTrip: return Theme.barkBrown
        case .workshop: return .orange
        case .festival: return .pink
        }
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var positions: [CGPoint] = []
        var height: CGFloat = 0

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > width && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            height = y + rowHeight
        }
    }
}

#Preview {
    BirdingEventsView()
        .frame(width: 400, height: 700)
}
