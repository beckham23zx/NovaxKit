import Foundation
import Security

/// Generic Keychain wrapper for storing/loading/deleting Data items.
/// Both Shard and TapLog can use this for any secure storage needs.
public enum KeychainHelper {

    @discardableResult
    public static func save(service: String, account: String, data: Data, accessible: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly) -> Bool {
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessible
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        return status == errSecSuccess
    }

    public static func load(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return data
    }

    public static func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// Convenience: save a JSON-serializable dictionary.
    public static func saveJSON(service: String, account: String, dict: [String: String]) -> Bool {
        guard let data = try? JSONSerialization.data(withJSONObject: dict) else { return false }
        return save(service: service, account: account, data: data)
    }

    /// Convenience: load a JSON dictionary.
    public static func loadJSON(service: String, account: String) -> [String: String]? {
        guard let data = load(service: service, account: account),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String]
        else { return nil }
        return dict
    }
}
