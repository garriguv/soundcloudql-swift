import Foundation
import UIKit

class AppCoordinator : Coordinator {
  let tabBarController: UITabBarController

  var childCoordinators: [Coordinator]

  init(_ tabBarController: UITabBarController) {
    self.tabBarController = tabBarController
    self.childCoordinators = []
  }

  func start() {
    self.tabBarController.setViewControllers([
      startProfile()
    ], animated: true)
  }

  private func startProfile() -> UINavigationController {
    let navigationController = UINavigationController()
    let profileCoordinator = ProfileCoordinator(navigationController, userId: "2")
    childCoordinators.append(profileCoordinator)
    profileCoordinator.start()
    return navigationController
  }
}
