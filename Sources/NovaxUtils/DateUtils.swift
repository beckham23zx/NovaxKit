import Foundation

/// Shared date formatting utilities used across both apps.
public enum NovaxDate {

    /// Returns today's date string in `yyyy-MM-dd` format.
    public static func todayString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
    }

    /// Returns a localized display string for today (e.g. "2026年4月14日 星期二").
    public static func todayDisplayString(locale: Locale = Locale(identifier: "zh_CN")) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy年M月d日 EEEE"
        fmt.locale = locale
        return fmt.string(from: Date())
    }

    /// ISO 8601 formatter (thread-safe).
    public static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        return f
    }()

    /// Parse an ISO 8601 date string.
    public static func fromISO(_ string: String) -> Date? {
        iso8601.date(from: string)
    }

    /// Format a date to ISO 8601 string.
    public static func toISO(_ date: Date) -> String {
        iso8601.string(from: date)
    }
}
