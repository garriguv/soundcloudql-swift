import Foundation
import UIKit

class PostedPlaylistsCoordinator {
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

extension PostedPlaylistsCoordinator: Coordinator, CoordinatorDelegate, CollectionTableViewControllerDelegate {
  func start() {
    let viewController = CollectionTableViewController()
    viewController.collectionEngine = GraphQLCollectionEngineDelegate<PostedPlaylistsCollection>(userId: userId)
    viewController.collectionDelegate = self
    viewController.title = "posted playlists"
    navigationController.pushViewController(viewController, animated: true)
  }
}
