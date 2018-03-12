enum UserAction {
    case loading
    case searched(result: Result<SearchUser.Response, Session.Error>)
    case loadedMore(result: Result<SearchUser.Response, Session.Error>, page: Int)
    case reloadCompleted
}

extension Actions where State == UserState {
    func search(query: String) -> Disposable {
        dispatch(action: .loading)
        
        let request = SearchUser(query: query, page: 1, perPage: 30)
        return Session.send(request: request).observe { result in
            self.dispatch(action: .searched(result: result))
        }
    }
    
    func loadMore(query: String, nextPage page: Int) -> Disposable {
        dispatch(action: .loading)
        
        let request = SearchUser(query: query, page: page, perPage: 30)
        return Session.send(request: request).observe { result in
            self.dispatch(action: .loadedMore(result: result, page: page))
        }
    }
    
    func reloadCompleted() {
        dispatch(action: .reloadCompleted)
    }
}
