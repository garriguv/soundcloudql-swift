import Foundation
import UIKit

class PostedPlaylistsCoordinator {
  private let navigationController: UINavigationController
  private let userId: String

  internal weak var delegate: CoordinatorDelegate?
  internal var childCoordinators: [Coordinator] = []

  init(_ navigationController: UINavigationController, userId: String, delegate: CoordinatorDelegate) {
    self.navigationController = navigationController
    self.userId = userId
    self.delegate = delegate
  }
}

extension PostedPlaylistsCoordinator: Coordinator {
  func start() {
    let viewController = CollectionTableViewController()
    viewController.collectionEngine = GraphQLCollectionEngineDelegate<PostedPlaylistsCollection>(userId: userId)
    viewController.collectionDelegate = self
    viewController.title = "posted playlists"
    navigationController.pushViewController(viewController, animated: true)
  }
}

extension PostedPlaylistsCoordinator: CollectionTableViewControllerDelegate {
  func viewDidDisappear() {
    delegate?.didFinishCoordinating(self)
  }
}

