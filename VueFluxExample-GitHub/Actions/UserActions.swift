enum UserAction {
    case searched(result: Result<SearchUser.Response, Session.Error>)
}

extension Actions where State == UserState {
    func search(query: String) -> Disposable {
        let request = SearchUser(query: query, page: 1, perPage: 100)
        return Session.send(request: request).observe { result in
            self.dispatch(action: .searched(result: result))
        }
    }
}
