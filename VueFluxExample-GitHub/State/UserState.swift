import Foundation

extension Computed where State == UserState {
    var cellModels: Constant<[UserCellModel]> {
        return state.cellModels.constant
    }
    
    var countText: Signal<String?> {
        return state.cellModels.signal.map { !$0.isEmpty ? "Top \($0.count)" : nil }
    }
    
    var isBackgroundMarkHidden: Signal<Bool> {
        return state.cellModels.signal.map { !$0.isEmpty }
    }
    
    var rateLimitText: Signal<String?> {
        return state.rateLimit.signal.map { $0?.displayText }
    }
    
    var refreshEnded: Signal<Void> {
        return state.progress.signal.filter { $0 != .searching }.map { _ in }
    }
}

final class UserState: State {
    typealias Action = UserAction
    typealias Mutations = UserMutations
    
    enum Progress {
        case `default`
        case searching
        case searched
        case searchFailed
    }
    
    fileprivate let progress = Variable(Progress.default)
    fileprivate let cellModels = Variable<[UserCellModel]>([])
    fileprivate let rateLimit = Variable<HeaderXRateLimit?>(nil)
}

struct UserMutations: Mutations {
    func commit(action: UserAction, state: UserState) {
        switch action {
        case .searching:
            state.progress.value = .searching
            
        case .searched(result: .success(let response)):
            state.cellModels.value = response.data.items.map(UserCellModel.init)
            state.rateLimit.value = response.rateLimit
            state.progress.value = .searched
            
        case .searched(result: .failure):
            state.cellModels.value.removeAll()
            state.progress.value = .searchFailed
        }
    }
}

private extension HeaderXRateLimit {
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var displayText: String? {
        if let remainingCount = Int(remaining), remainingCount > 0 {
            return "API rate limit: \(remaining)/\(limit)"
        } else if let resetDate = TimeInterval(reset).map(Date.init(timeIntervalSince1970:)) {
            return "API rate limit reset at: \(type(of: self).displayFormatter.string(from: resetDate))"
        } else {
            return nil
        }
    }
}
