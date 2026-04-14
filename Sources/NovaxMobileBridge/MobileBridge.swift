import Foundation

/// Unified JSON parser for Go Mobile bridge responses.
/// Both Shard and TapLog Go layers return `{"ok":true/false, ...}` JSON strings.
public enum MobileBridge {

    /// Parse a JSON string returned from Go Mobile into a dictionary.
    public static func parseJSON(_ str: String) -> [String: Any] {
        guard let data = str.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return [:] }
        return json
    }
}

/// Generic result wrapper for Go Mobile JSON responses.
/// Automatically handles the `{"ok": true/false, "error": "..."}` convention.
public struct MobileResult<T: Decodable> {
    public let ok: Bool
    public let error: String?
    public let raw: [String: Any]

    public init(_ jsonString: String) {
        let dict = MobileBridge.parseJSON(jsonString)
        self.raw = dict
        self.ok = dict["ok"] as? Bool ?? false
        self.error = dict["error"] as? String
    }

    /// Decode a specific key from the raw response into `T`.
    public func decode(key: String) -> T? {
        guard let value = raw[key] else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: value) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

/// Debug-only logging helper that wraps NSLog with a tag prefix.
public func novaxLog(_ tag: String, _ msg: String, _ args: CVarArg...) {
    #if DEBUG
    novaxLogv(tag, msg, args)
    #endif
}

/// Array-based variant for forwarding from other variadic wrappers.
public func novaxLogv(_ tag: String, _ msg: String, _ args: [CVarArg]) {
    #if DEBUG
    withVaList(args) { NSLogv("[\(tag)] " + msg, $0) }
    #endif
}
