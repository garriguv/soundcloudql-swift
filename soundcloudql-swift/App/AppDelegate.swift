import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var appCoordinator: AppCoordinator?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    let tabBarController = UITabBarController()
    window?.rootViewController = tabBarController

    appCoordinator = AppCoordinator(tabBarController)
    appCoordinator?.start()

    window?.makeKeyAndVisible()
    return true
  }
}
