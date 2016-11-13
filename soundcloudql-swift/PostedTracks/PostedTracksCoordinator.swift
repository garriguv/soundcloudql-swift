import Foundation
import UIKit

class PostedTracksCoordinator {
  fileprivate let navigationController: UINavigationController
  fileprivate let userId: String

  internal weak var delegate: CoordinatorDelegate?
  internal var childCoordinators: [Coordinator] = []

  init(_ navigationController: UINavigationController, userId: String, delegate: CoordinatorDelegate) {
    self.navigationController = navigationController
    self.userId = userId
    self.delegate = delegate
  }
}

extension PostedTracksCoordinator: Coordinator, CoordinatorDelegate, CollectionTableViewControllerDelegate {
  func start() {
    let viewController = CollectionTableViewController()
    viewController.collectionEngine = GraphQLCollectionEngineDelegate<PostedTracksCollection>(userId: userId)
    viewController.collectionDelegate = self
    viewController.title = "posted tracks"
    navigationController.pushViewController(viewController, animated: true)
  }
}
