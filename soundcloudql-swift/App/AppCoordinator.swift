import Foundation
import UIKit

class AppCoordinator {
  private let tabBarController: UITabBarController

  private var childCoordinators: [Coordinator]

  init(_ tabBarController: UITabBarController) {
    self.tabBarController = tabBarController
    self.childCoordinators = []
  }
}

extension AppCoordinator: Coordinator {
  func start() {
    self.tabBarController.setViewControllers([
      startProfile()
    ], animated: true)
  }
}

extension AppCoordinator {
  private func startProfile() -> UINavigationController {
    let navigationController = UINavigationController()
    let profileCoordinator = ProfileCoordinator(navigationController, userId: "2")
    childCoordinators.append(profileCoordinator)
    profileCoordinator.start()
    return navigationController
  }
}
