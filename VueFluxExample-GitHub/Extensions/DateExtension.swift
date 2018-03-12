import Foundation
import Alembic

extension Date: Parsable {
    private static let timezoneFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    public static func value(from json: JSON) throws -> Date {
        guard let date = try timezoneFormatter.date(from: json.value()) else {
            throw JSON.Error.dataCorrupted(value: json.rawValue, description: "The given data was not valid date format string.")
        }
        
        return date
    }
}
