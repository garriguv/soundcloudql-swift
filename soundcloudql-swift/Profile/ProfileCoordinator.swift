import Foundation
import UIKit

class ProfileCoordinator : Coordinator {
  private let navigationController: UINavigationController
  private let userId: String

  init(_ navigationController: UINavigationController, userId: String) {
    self.navigationController = navigationController
    self.userId = userId
  }

  func start() {
    let viewController = ProfileTableViewController()
    viewController.userId = userId
    viewController.title = "Profile"
    navigationController.pushViewController(viewController, animated: false)
  }
}
