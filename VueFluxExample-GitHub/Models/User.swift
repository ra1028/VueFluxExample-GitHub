import Foundation
import Alembic

struct User: Parsable {
    let id: Int64
    let login: String
    let avatarUrl: URL
    let htmlUrl: URL
    
    static func value(from json: JSON) throws -> User {
        return try User(
            id: json.value(for: "id"),
            login: json.value(for: "login"),
            avatarUrl: json.value(for: "avatar_url"),
            htmlUrl: json.value(for: "html_url")
        )
    }
}
