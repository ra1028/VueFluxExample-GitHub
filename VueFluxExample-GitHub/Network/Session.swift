import Foundation
import func Alamofire.request
import Alembic

 struct Session {
     enum Error: Swift.Error {
        case request
        case connection
        case other(error: Swift.Error)
        case unknown
    }
    
     static func send<T: Request>(request: T) -> Signal<Result<T.Response, Error>> {
        return .init { send in
            let task = Alamofire.request(
                request.url,
                method: request.method,
                parameters: request.parameters,
                encoding: request.parameterEncoding,
                headers: request.headers
                )
                .validate()
                .responseData(queue: .global()) { dataResponse in
                    do {
                        switch dataResponse.error {
                        case let error as NSError where error.code == NSURLErrorNotConnectedToInternet:
                            throw Error.connection
                            
                        case .some:
                            throw Error.request
                            
                        case .none:
                            break
                        }
                        
                        guard let data = dataResponse.data, let httpUrlResponse = dataResponse.response else {
                            throw Error.unknown
                        }
                        
                        let response = try request.parse(data: data, response: httpUrlResponse)
                        
                        send(.success(response))
                        
                    } catch let error {
                        let error = (error as? Error) ?? .other(error: error)
                        send(.failure(error))
                    }
            }
            
            return AnyDisposable(task.cancel)
        }
    }
    
    private init() {}
}
