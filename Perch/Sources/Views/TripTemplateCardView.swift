import SwiftUI

struct TripTemplateCardView: View {
    let template: TripTemplate
    var onUse: (() -> Void)?
    var onDelete: (() -> Void)?
    let isCompact: Bool

    init(template: TripTemplate, isCompact: Bool = false, onUse: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.template = template
        self.isCompact = isCompact
        self.onUse = onUse
        self.onDelete = onDelete
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: template.tripType.icon)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.terracotta)
                            .frame(width: 20, height: 20)
                            .background(Theme.terracotta.opacity(0.15))
                            .cornerRadius(6)

                        Text(template.tripType.displayName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Theme.terracotta)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }

                    Text(template.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(2)
                }

                Spacer()

                if template.id < 0 {
                    Text("Pre-built")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.surfaceElevated)
                        .cornerRadius(6)
                }
            }

            if !isCompact {
                // Destinations path
                if !template.destinations.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(template.destinations.prefix(4)) { dest in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Theme.sage)
                                    .frame(width: 6, height: 6)

                                Text(dest.city)
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.textPrimary)

                                if let country = dest.country {
                                    Text("· \(country)")
                                        .font(.system(size: 13))
                                        .foregroundColor(Theme.textSecondary)
                                }

                                Spacer()
                            }
                        }

                        if template.destinations.count > 4 {
                            Text("+\(template.destinations.count - 4) more")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .padding(.top, 8)
                }

                Divider()
                    .background(Theme.divider)
                    .padding(.vertical, 10)

                // Meta row
                HStack(spacing: 16) {
                    MetaTag(icon: "calendar", value: "\(template.expectedDurationDays)d")
                    MetaTag(icon: transportIcon, value: transportName)
                }

                // Notes
                if !template.notes.isEmpty {
                    Text(template.notes)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                        .italic()
                        .padding(.top, 8)
                        .lineLimit(2)
                }

                // Action
                if let onUse = onUse {
                    Button {
                        onUse()
                    } label: {
                        HStack {
                            Image(systemName: "airplane.departure")
                            Text("Use Template")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Theme.terracotta)
                        .cornerRadius(8)
                    }
                    .padding(.top, 12)
                }
            } else {
                // Compact: just show city count and duration
                HStack(spacing: 12) {
                    Text("\(template.destinations.count) city\(template.destinations.count == 1 ? "" : "s")")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)

                    Text("·")
                        .foregroundColor(Theme.textSecondary)

                    Text("\(template.expectedDurationDays) days")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(.top, 6)
            }
        }
        .padding(16)
        .background(Theme.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: template.id < 0 ? 0 : 1)
        )
    }

    private var transportIcon: String {
        switch template.transportMode {
        case "car": return "car.fill"
        case "train": return "tram.fill"
        case "bus": return "bus.fill"
        default: return "airplane"
        }
    }

    private var transportName: String {
        switch template.transportMode {
        case "car": return "Car"
        case "train": return "Train"
        case "bus": return "Bus"
        default: return "Flight"
        }
    }

    private var borderColor: Color {
        Theme.divider
    }
}

struct MetaTag: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
            Text(value)
                .font(.system(size: 12))
                .foregroundColor(Theme.textSecondary)
        }
    }
}

struct TripTemplateCardPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Theme.surfaceElevated)
                .frame(width: 60, height: 20)

            RoundedRectangle(cornerRadius: 4)
                .fill(Theme.surfaceElevated)
                .frame(width: 140, height: 20)

            RoundedRectangle(cornerRadius: 4)
                .fill(Theme.surfaceElevated)
                .frame(height: 14)
                .padding(.top, 4)
        }
        .padding(16)
        .background(Theme.surface.opacity(0.5))
        .cornerRadius(16)
        .redacted(reason: .placeholder)
    }
}
