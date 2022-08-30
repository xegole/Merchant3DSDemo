import Foundation

extension Date {
    /// Returns the current Date in UTC time zone
    ///
    /// - Returns: String representation of the current UTC Date in yyyyMMddHHmmss format
    func toUTCString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let currentFormattedTime = dateFormatter.string(from: self)
        return currentFormattedTime
    }
}
