import Foundation
import UIKit

class ProfileCoordinator {
  private let navigationController: UINavigationController
  private let userId: String

  private var childCoordinators: [Coordinator]

  init(_ navigationController: UINavigationController, userId: String) {
    self.navigationController = navigationController
    self.userId = userId
    self.childCoordinators = []
  }
}

extension ProfileCoordinator: Coordinator {
  func start() {
    let viewController = ProfileTableViewController()
    viewController.userId = userId
    viewController.profileDelegate = self
    navigationController.pushViewController(viewController, animated: false)
  }
}

extension ProfileCoordinator: ProfileTableViewControllerDelegate {
  func didTapMorePostedTracks() {
    let postedTracksCoordinator = PostedTracksCoordinator(navigationController, userId: userId)
    childCoordinators.append(postedTracksCoordinator)
    postedTracksCoordinator.start()
  }

  func didTapMoreLikedTracks() {
    print(__FUNCTION__)
  }
}
