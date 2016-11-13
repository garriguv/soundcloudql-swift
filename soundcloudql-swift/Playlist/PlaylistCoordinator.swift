import Foundation
import UIKit

class PlaylistCoordinator {
  fileprivate let navigationController: UINavigationController
  fileprivate let playlistId: String

  internal weak var delegate: CoordinatorDelegate?
  internal var childCoordinators: [Coordinator] = []

  init(_ navigationController: UINavigationController, playlistId: String, delegate: CoordinatorDelegate) {
    self.navigationController = navigationController
    self.playlistId = playlistId
    self.delegate = delegate
  }
}

extension PlaylistCoordinator: Coordinator, CoordinatorDelegate {
  func start() {
    let viewController = PlaylistTableViewController()
    viewController.playlistId = playlistId
    viewController.playlistDelegate = self
    navigationController.pushViewController(viewController, animated: true)
  }
}

extension PlaylistCoordinator: PlaylistTableViewControllerDelegate {
  func viewDidDisappear() {
    delegate?.didFinishCoordinating(self)
  }

  func didTapTrack(trackId: String, permalinkUrl: String) {
    if let permalinkURL = URL(string: permalinkUrl) {
      UIApplication.shared.open(permalinkURL, options: [:], completionHandler: nil)
    }
  }

  func didTapUser(userId: String, permalinkUrl: String) {
    let profileCoordinator = ProfileCoordinator(navigationController, userId: userId, delegate: self)
    childCoordinators.append(profileCoordinator)
    profileCoordinator.start()
  }
}
