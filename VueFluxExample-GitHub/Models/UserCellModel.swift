import Foundation

struct UserCellModel {
    let id: Int64
    let name: String
    let avatarUrl: URL
    let url: URL
}

extension UserCellModel {
    init(user: User) {
        self.init(id: user.id, name: user.login, avatarUrl: user.avatarUrl, url: user.htmlUrl)
    }
}
