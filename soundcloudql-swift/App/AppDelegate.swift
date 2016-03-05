import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var appCoordinator: AppCoordinator?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    let tabBarController = UITabBarController()
    window?.rootViewController = tabBarController

    appCoordinator = AppCoordinator(tabBarController)
    appCoordinator?.start()

    window?.makeKeyAndVisible()
    return true
  }

}
