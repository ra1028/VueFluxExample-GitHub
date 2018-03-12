import Foundation
import Alembic

extension URL: Parsable {
    public static func value(from json: JSON) throws -> URL {
        guard let url = try URL(string: json.value()) else {
            throw JSON.Error.dataCorrupted(value: json.rawValue, description: "The given data was not valid url string.")
        }
        return url
    }
}
