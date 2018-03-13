import Alamofire
import Alembic

struct SearchUser: GitHubRequest {
    let path = "/search/users"
    let method = HTTPMethod.get
    let parameters: Parameters?
    
    init(
        query: String,
        sort: Sort? = nil,
        order: Order? = nil,
        page: Int,
        perPage: Int) {
        var parameters: Parameters = ["q": query, "page": page, "per_page": perPage]
        parameters["sort"] = sort
        parameters["order"] = order
        self.parameters = parameters
    }
    
    func parseData(data: Data) throws -> [User] {
        return try JSON(data: data).value(for: "items")
    }
}

extension SearchUser {
    enum Sort: String {
        case followers
        case repositories
        case joined
    }
    
    enum Order: String {
        case asc
        case desc
    }
}
