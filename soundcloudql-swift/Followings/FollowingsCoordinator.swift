import Foundation
import UIKit

class FollowingsCoordinator {
  private let navigationController: UINavigationController
  private let userId: String
  internal weak var delegate: CoordinatorDelegate?

  init(_ navigationController: UINavigationController, userId: String, delegate: CoordinatorDelegate) {
    self.navigationController = navigationController
    self.userId = userId
    self.delegate = delegate
  }
}

extension FollowingsCoordinator: Coordinator {
  func start() {
    let viewController = CollectionTableViewController()
    viewController.collectionEngine = GraphQLCollectionEngineDelegate<FollowingsCollection>(userId: userId)
    viewController.title = "followings"
    navigationController.pushViewController(viewController, animated: true)
  }
}

extension FollowingsCoordinator: CollectionTableViewControllerDelegate {
  func viewDidDisappear() {
    delegate?.didFinishCoordinating(self)
  }
}

