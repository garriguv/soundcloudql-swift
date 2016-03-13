import Foundation
import UIKit

class PlaylistCoordinator {
  private let navigationController: UINavigationController
  private let playlistId: String

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
}
