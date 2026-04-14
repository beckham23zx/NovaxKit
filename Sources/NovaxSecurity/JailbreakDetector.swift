import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Detects jailbroken iOS devices via filesystem probes, URL schemes, and sandbox escape tests.
public enum JailbreakDetector {
    public static var isJailbroken: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/usr/bin/ssh",
            "/var/jb"
        ]

        for path in suspiciousPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        if canOpenCydia() { return true }
        if canWriteOutsideSandbox() { return true }

        return false
        #endif
    }

    private static func canOpenCydia() -> Bool {
        #if canImport(UIKit)
        guard let url = URL(string: "cydia://package/com.example.package") else { return false }
        return UIApplication.shared.canOpenURL(url)
        #else
        return false
        #endif
    }

    private static func canWriteOutsideSandbox() -> Bool {
        let path = "/private/jailbreak_test_\(UUID().uuidString)"
        do {
            try "test".write(toFile: path, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
}
