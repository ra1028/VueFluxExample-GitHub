import Foundation

struct UserCellModel: CellModel {
    let id: Int64
    let name: String
    let avatarUrl: URL
    let url: URL
    
    var primaryKey: Int64 {
        return id
    }
}

extension UserCellModel {
    init(user: User) {
        self.init(id: user.id, name: user.login, avatarUrl: user.avatarUrl, url: user.htmlUrl)
    }
}
