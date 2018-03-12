import Foundation
import DeepDiff

extension Computed where State == UserState {
    var cellModels: [UserCellModel] {
        return state.searchStatus.value.cellModels
    }
    
    var cellModelChanges: Signal<[Change<UserCellModel>]> {
        return state.searchStatus.signal
            .map { $0.cellModels }
            .combinePrevious()
            .map { diff(old: $0, new: $1) }
    }
    
    var countText: Signal<String> {
        return state.searchStatus.signal.map { $0.countText }
    }
    
    var rateLimitText: Signal<String?> {
        return state.searchStatus.signal.map { $0.rateLimitText }
    }
    
    var refreshEnded: Signal<Void> {
        return state.progress.signal
            .filter { progress in
                if case .loading = progress { return false }
                return true
            }
            .map { _ in }
    }
    
    var isBackgroundMarkHidden: Signal<Bool> {
        return state.searchStatus.signal
            .map { !$0.cellModels.isEmpty }
    }
    
    var isLoadMoreEnabled: Bool {
        return state.isLoadmoreEnabled.value
    }
    
    var currentPage: Int {
        return state.searchStatus.value.currentPage
    }
}

final class UserState: State {
    typealias Action = UserAction
    typealias Mutations = UserMutations
    
    enum Progress {
        case `default`
        case loading
        case searched(hasNext: Bool)
        case loadedMore(hasNext: Bool)
        case searchFailed
        case loadMoreFailed
    }
    
    struct SearchStatus {
        let cellModels: [UserCellModel]
        let totalCount: Int
        let currentPage: Int
        let rateLimit: HeaderXRateLimit?
    }
    
    fileprivate let progress = Variable(Progress.default)
    fileprivate let searchStatus = Variable(SearchStatus.default)
    fileprivate let isLoadmoreEnabled = Variable(false)
}

struct UserMutations: Mutations {
    func commit(action: UserAction, state: UserState) {
        switch action {
        case .loading:
            state.isLoadmoreEnabled.value = false
            state.progress.value = .loading
            
        case .searched(result: .success(let response)):
            let cellModels = response.data.items.map(UserCellModel.init)
            let totalCount = response.data.totalCount
            let hasNext = !cellModels.isEmpty
            state.searchStatus.value = .init(cellModels: cellModels, totalCount: totalCount, currentPage: 1, rateLimit: response.rateLimit)
            state.progress.value = .searched(hasNext: hasNext)
            
        case .loadedMore(result: .success(let response), let page):
            let cellModels = response.data.items.map(UserCellModel.init)
            let totalCount = response.data.totalCount
            let hasNext = !cellModels.isEmpty
            state.searchStatus.value = .init(cellModels: state.searchStatus.value.cellModels + cellModels, totalCount: totalCount, currentPage: page, rateLimit: response.rateLimit)
            state.progress.value = .loadedMore(hasNext: hasNext)
            
        case .searched(result: .failure):
            let rateLimit = state.searchStatus.value.rateLimit
            state.searchStatus.value = .init(cellModels: [], totalCount: 0, currentPage: 0, rateLimit: rateLimit)
            state.progress.value = .searchFailed
            
        case .loadedMore(result: .failure, page: _):
            state.isLoadmoreEnabled.value = true
            state.progress.value = .loadMoreFailed
            
        case .reloadCompleted:
            state.isLoadmoreEnabled.value = state.progress.value.hasNext
        }
    }
}

private extension UserState.Progress {
    var hasNext: Bool {
        switch self {
        case .searched(let hasNext), .loadedMore(let hasNext):
            return hasNext
            
        default:
            return false
        }
    }
}

private extension UserState.SearchStatus {
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()
    
    static var `default`: UserState.SearchStatus {
        return .init(cellModels: [], totalCount: 0, currentPage: 0, rateLimit: nil)
    }
    
    var countText: String {
        return "\(cellModels.count)/\(totalCount)"
    }
    
    var rateLimitText: String? {
        guard let rateLimit = rateLimit else { return nil }
        
        if let remainingCount = Int(rateLimit.remaining), remainingCount > 0 {
            return "API rate limit: \(rateLimit.remaining)/\(rateLimit.limit)"
        } else if let resetDate = TimeInterval(rateLimit.reset).map(Date.init(timeIntervalSince1970:)) {
            return "API rate limit reset at: \(UserState.SearchStatus.displayFormatter.string(from: resetDate))"
        } else {
            return nil
        }
    }
}
