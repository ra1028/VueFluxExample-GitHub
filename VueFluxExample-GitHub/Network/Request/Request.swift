import Alamofire

protocol Request {
    associatedtype Response
    
    var baseUrl: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var parameterEncoding: ParameterEncoding { get }
    var headers: HTTPHeaders? { get }
    
    func parse(data: Data, response: HTTPURLResponse) throws -> Response
}

extension Request {
    var url: URL {
        return baseUrl.appendingPathComponent(path)
    }
}
