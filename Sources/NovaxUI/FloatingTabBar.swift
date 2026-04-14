import SwiftUI

/// Tab definition for the floating tab bar.
public struct NovaxTab {
    public let icon: String
    public let selectedIcon: String
    public let label: String

    public init(icon: String, selectedIcon: String, label: String) {
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.label = label
    }
}

/// A frosted-glass floating tab bar, shared across Shard and TapLog.
/// Usage:
/// ```swift
/// FloatingTabBar(tabs: myTabs, selection: $selectedTab, tintColor: .navy)
/// ```
public struct FloatingTabBar: View {
    public let tabs: [NovaxTab]
    @Binding public var selection: Int
    public var tintColor: Color

    public init(tabs: [NovaxTab], selection: Binding<Int>, tintColor: Color = .blue) {
        self.tabs = tabs
        self._selection = selection
        self.tintColor = tintColor
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { idx, tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = idx
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: selection == idx ? tab.selectedIcon : tab.icon)
                            .font(.system(size: 20))
                            .fontWeight(selection == idx ? .semibold : .regular)
                            .contentTransition(.symbolEffect(.replace))
                            .frame(height: 24)
                        Text(tab.label)
                            .font(.system(size: 10, weight: selection == idx ? .semibold : .regular))
                    }
                    .foregroundStyle(tintColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(.white.opacity(0.45), lineWidth: 0.5)
                )
                .shadow(color: tintColor.opacity(0.06), radius: 28, y: 10)
                .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 2)
    }
}
