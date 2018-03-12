import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configure()
        return true
    }
}

private extension AppDelegate {
    func configure() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UserViewController.instantiate()
        self.window = window
        window.makeKeyAndVisible()
    }
}
