import Alamofire
import Alembic

private let gitHubAccessToken: String? = {
    guard let accessToken = Bundle.main.infoDictionary?["GitHubAccessToken"] as? String, !accessToken.isEmpty else {
        print("💡Access token is not set, See README💡")
        return nil
    }
    return accessToken
}()

protocol GitHubRequest: Request {
    associatedtype ResponseData
    
    func parseData(data: Data) throws -> ResponseData
}

extension GitHubRequest {
    var baseUrl: URL {
        return Config.Url.gitHubApiBaseUrl
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding()
    }
    
    var headers: HTTPHeaders? {
        return gitHubAccessToken.map { ["Authorization": "token \($0)"] }
    }
}

extension GitHubRequest {
    func parse(data: Data, response: HTTPURLResponse) throws -> (data: ResponseData, rateLimit: HeaderXRateLimit) {
        let data = try parseData(data: data)
        let rateLimit: HeaderXRateLimit = try JSON(response.allHeaderFields).value()
        return (data: data, rateLimit: rateLimit)
    }
}

extension GitHubRequest where ResponseData: Parsable {
    func parseData(data: Data) throws -> ResponseData {
        return try JSON(data: data).value()
    }
}
