import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Device information utilities.
public enum NovaxDevice {

    /// A stable per-device identifier (identifierForVendor or fallback UUID stored in UserDefaults).
    public static var deviceID: String {
        #if canImport(UIKit)
        if let id = UIDevice.current.identifierForVendor?.uuidString {
            return id
        }
        #endif
        let key = "com.novax.device_id"
        if let stored = UserDefaults.standard.string(forKey: key) {
            return stored
        }
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }

    /// Current OS platform string.
    public static var platform: String {
        #if os(iOS)
        return "ios"
        #elseif os(macOS)
        return "macos"
        #else
        return "unknown"
        #endif
    }
}
