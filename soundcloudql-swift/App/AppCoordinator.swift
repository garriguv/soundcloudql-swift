import Foundation
import UIKit

class AppCoordinator {
  fileprivate let tabBarController: UITabBarController

  internal weak var delegate: CoordinatorDelegate? = nil
  internal var childCoordinators: [Coordinator]

  init(_ tabBarController: UITabBarController) {
    self.tabBarController = tabBarController
    self.childCoordinators = []
  }
}

extension AppCoordinator: Coordinator {
  func start() {
    self.tabBarController.setViewControllers([
      startProfile(),
    ], animated: true)
  }
}

extension AppCoordinator: CoordinatorDelegate {}

extension AppCoordinator {
  fileprivate func startProfile() -> UINavigationController {
    let navigationController = UINavigationController()
    let profileCoordinator = ProfileCoordinator(navigationController, userId: "2", delegate: self)
    childCoordinators.append(profileCoordinator)
    profileCoordinator.start()
    return navigationController
  }
}
