import Foundation
import UIKit

class PostedTracksCoordinator: Coordinator {
  private let navigationController: UINavigationController
  private let userId: String
  internal weak var delegate: CoordinatorDelegate?

  init(_ navigationController: UINavigationController, userId: String, delegate: CoordinatorDelegate) {
    self.navigationController = navigationController
    self.userId = userId
    self.delegate = delegate
  }

  func start() {
    let viewController = CollectionTableViewController()
    viewController.collectionEngine = GraphQLCollectionEngineDelegate<PostedTracksCollection>(userId: userId)
    viewController.title = "posted tracks"
    navigationController.pushViewController(viewController, animated: true)
  }
}
