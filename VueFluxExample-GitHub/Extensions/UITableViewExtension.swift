import UIKit
import DeepDiff

extension UITableView {
    func reloadWithoutAnimation<T: Hashable>(changes: [Change<T>], completion: @escaping ((Bool) -> Void) = { _ in }) {
        UIView.performWithoutAnimation {
            reload(changes: changes, completion: completion)
        }
    }
    
    func register<T: UITableViewCell>(cellType: T.Type) where T: Reusable & NibLoadable {
        register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func register<T: UITableViewCell>(cellType: T.Type) where T: Reusable {
        register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T where T: Reusable {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else { fatalError() }
        return cell
    }
}
