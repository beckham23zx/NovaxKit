import SwiftUI

/// Empty state placeholder with icon and message.
public struct NovaxEmptyStateView: View {
    public let systemImage: String
    public let title: String
    public let subtitle: String?

    public init(systemImage: String, title: String, subtitle: String? = nil) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(.secondary.opacity(0.6))
            Text(title)
                .foregroundStyle(.secondary)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary.opacity(0.7))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

/// Rounded card container with system background.
public struct NovaxCard<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }
}
