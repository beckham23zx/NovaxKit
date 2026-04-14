import Foundation
#if canImport(UIKit)
import UIKit

/// Copies text to clipboard with local-only restriction and automatic expiry.
public enum SecureClipboard {
    private static var clearTimer: Timer?

    public static func copyWithAutoExpiry(_ text: String, seconds: TimeInterval = 30) {
        UIPasteboard.general.setItems(
            [[UIPasteboard.typeAutomatic: text]],
            options: [
                .localOnly: true,
                .expirationDate: Date().addingTimeInterval(seconds)
            ]
        )
        clearTimer?.invalidate()
        clearTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
            if UIPasteboard.general.string == text {
                UIPasteboard.general.string = ""
            }
        }
    }
}
#endif
