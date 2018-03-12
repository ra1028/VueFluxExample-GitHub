import UIKit

protocol StoryboardInitial: class where Self: UIViewController {
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle? { get }
}

extension StoryboardInitial {
    static var storyboardName: String {
        return .init(describing: self)
    }
    
    static var storyboardBundle: Bundle? {
        return .init(for: self)
    }
    
    static func instantiate() -> Self {
        return UIStoryboard(name: storyboardName, bundle: storyboardBundle).instantiateInitialViewController() as! Self // swiftlint:disable:this force_cast
    }
}
