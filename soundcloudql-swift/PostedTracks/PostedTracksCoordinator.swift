import Foundation
import UIKit

class PostedTracksCoordinator: Coordinator {
  private let navigationController: UINavigationController
  private let userId: String

  init(_ navigationController: UINavigationController, userId: String) {
    self.navigationController = navigationController
    self.userId = userId
  }

  func start() {
    let viewController = PostedTracksTableViewController()
    viewController.userId = userId
    navigationController.pushViewController(viewController, animated: true)
  }
}
