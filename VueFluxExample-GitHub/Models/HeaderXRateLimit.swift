import Alembic

struct HeaderXRateLimit: Parsable {
    let limit: String
    let remaining: String
    let reset: String
    
    static func value(from json: JSON) throws -> HeaderXRateLimit {
        return try HeaderXRateLimit(
            limit: json.value(for: "X-RateLimit-Limit"),
            remaining: json.value(for: "X-RateLimit-Remaining"),
            reset: json.value(for: "X-RateLimit-Reset")
        )
    }
}
