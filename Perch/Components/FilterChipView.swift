import SwiftUI

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Theme.forestGreen : Theme.surface)
                .foregroundColor(isSelected ? .white : Theme.textPrimary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct FilterChipGroupView: View {
    let filters: [String]
    @Binding var selectedFilter: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChipView(
                    title: "All",
                    isSelected: selectedFilter == nil
                ) {
                    selectedFilter = nil
                }

                ForEach(filters, id: \.self) { filter in
                    FilterChipView(
                        title: filter,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    VStack {
        FilterChipGroupView(
            filters: ["Waterfowl", "Hawks", "Herons", "Shorebirds", "Warblers"],
            selectedFilter: .constant("Hawks")
        )
    }
    .padding()
    .background(Theme.cream)
}
