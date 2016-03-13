import Foundation
import UIKit

class LikedTracksCoordinator {
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

extension LikedTracksCoordinator: Coordinator {
  func start() {
    let viewController = CollectionTableViewController()
    viewController.collectionEngine = GraphQLCollectionEngineDelegate<LikedTracksCollection>(userId: userId)
    viewController.collectionDelegate = self
    viewController.title = "liked tracks"
    navigationController.pushViewController(viewController, animated: true)
  }
}

extension LikedTracksCoordinator: CollectionTableViewControllerDelegate {
  func viewDidDisappear() {
    delegate?.didFinishCoordinating(self)
  }
}
