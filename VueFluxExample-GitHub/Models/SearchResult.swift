import Alembic

struct SearchResult<Item: Parsable>: Parsable {
    let totalCount: Int
    let items: [Item]
    
    static func value(from json: JSON) throws -> SearchResult<Item> {
        return try SearchResult(
            totalCount: json.value(for: "total_count"),
            items: json.value(for: "items")
        )
    }
}
