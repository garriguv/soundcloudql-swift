import Foundation
import UIKit

class PostedTracksCoordinator {
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

extension PostedTracksCoordinator: Coordinator {
  func start() {
    let viewController = CollectionTableViewController()
    viewController.collectionEngine = GraphQLCollectionEngineDelegate<PostedTracksCollection>(userId: userId)
    viewController.collectionDelegate = self
    viewController.title = "posted tracks"
    navigationController.pushViewController(viewController, animated: true)
  }
}

extension PostedTracksCoordinator: CollectionTableViewControllerDelegate {
  func viewDidDisappear() {
    delegate?.didFinishCoordinating(self)
  }
}
