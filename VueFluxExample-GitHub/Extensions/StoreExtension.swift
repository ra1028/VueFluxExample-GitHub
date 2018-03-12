import Foundation

private let storeQueue = DispatchQueue(label: "com.ryo.VueFluxExample-GitHub.store.executor")

extension Store {
    convenience init(state: State, mutations: State.Mutations) {
        self.init(state: state, mutations: mutations, executor: .queue(storeQueue))
    }
}
