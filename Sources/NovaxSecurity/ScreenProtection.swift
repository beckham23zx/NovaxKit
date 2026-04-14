import Foundation
#if canImport(UIKit)
import UIKit

/// Blocks screen recording and screenshots by overlaying a privacy shield.
public final class ScreenProtection {
    public static let shared = ScreenProtection()

    private var overlayView: UIView?

    /// Call once at app launch to start monitoring for screen capture.
    public func startMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDetectCapture),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )

        if UIScreen.main.isCaptured {
            showOverlay()
        }
    }

    @objc private func didDetectCapture() {
        if UIScreen.main.isCaptured {
            showOverlay()
        } else {
            hideOverlay()
        }
    }

    private func showOverlay() {
        DispatchQueue.main.async {
            guard self.overlayView == nil else { return }
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else { return }

            let overlay = UIView(frame: window.bounds)
            overlay.backgroundColor = .white
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            let icon = UIImageView(image: UIImage(systemName: "shield.lock.fill"))
            icon.tintColor = UIColor(red: 0.11, green: 0.11, blue: 0.31, alpha: 1)
            icon.contentMode = .scaleAspectFit
            icon.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
            icon.center = CGPoint(x: overlay.bounds.midX, y: overlay.bounds.midY - 20)
            icon.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            overlay.addSubview(icon)

            let label = UILabel()
            label.text = "内容已保护"
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: 14)
            label.sizeToFit()
            label.center = CGPoint(x: overlay.bounds.midX, y: overlay.bounds.midY + 30)
            label.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            overlay.addSubview(label)

            window.addSubview(overlay)
            self.overlayView = overlay
        }
    }

    private func hideOverlay() {
        DispatchQueue.main.async {
            self.overlayView?.removeFromSuperview()
            self.overlayView = nil
        }
    }
}
#endif
