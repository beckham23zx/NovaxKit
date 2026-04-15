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

/// Frosted-glass card with thin material background and subtle border highlight.
public struct NovaxGlassCard<Content: View>: View {
    public let cornerRadius: CGFloat
    public let content: Content

    public init(cornerRadius: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background(
                shape.fill(.thinMaterial)
                    .overlay(shape.fill(.white.opacity(0.08)))
                    .overlay(
                        shape.strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.55), .white.opacity(0.12)],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                    )
                    .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
            )
    }
}

extension View {
    /// Apply frosted-glass background with rounded corners.
    public func novaxGlassBackground(cornerRadius: CGFloat = 20) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self.background(
            shape.fill(.thinMaterial)
                .overlay(shape.fill(.white.opacity(0.08)))
                .overlay(
                    shape.strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.55), .white.opacity(0.12)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
                )
                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        )
    }
}

/// A layout that wraps subviews to the next row when horizontal space runs out.
public struct NovaxWrappingHStack: Layout {
    public var alignment: HorizontalAlignment
    public var spacing: CGFloat

    public init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 8) {
        self.alignment = alignment
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (idx, pos) in result.positions.enumerated() {
            subviews[idx].place(
                at: CGPoint(x: bounds.minX + pos.x, y: bounds.minY + pos.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxW = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxW && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
