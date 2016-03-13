import Foundation
import UIKit

class ProfileCoordinator {
  private let navigationController: UINavigationController
  private let userId: String
  internal weak var delegate: CoordinatorDelegate?

  private var childCoordinators: [Coordinator] = []

  init(_ navigationController: UINavigationController, userId: String, delegate: CoordinatorDelegate) {
    self.navigationController = navigationController
    self.userId = userId
    self.delegate = delegate
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

extension ProfileCoordinator: CoordinatorDelegate {
  func didFinishCoordinating<T:Coordinator>(coordinator: T) {
  }
}

extension ProfileCoordinator: ProfileTableViewControllerDelegate {
  func didTapFollowers() {
    let followersCoordinator = FollowersCoordinator(navigationController, userId: userId, delegate: self)
    childCoordinators.append(followersCoordinator)
    followersCoordinator.start()
  }

  func didTapFollowings() {
    print(__FUNCTION__)
  }

  func didTapMorePostedTracks() {
    let postedTracksCoordinator = PostedTracksCoordinator(navigationController, userId: userId, delegate: self)
    childCoordinators.append(postedTracksCoordinator)
    postedTracksCoordinator.start()
  }

  func didTapMoreLikedTracks() {
    let likedTracksCoordinator = LikedTracksCoordinator(navigationController, userId: userId, delegate: self)
    childCoordinators.append(likedTracksCoordinator)
    likedTracksCoordinator.start()
  }

  func didTapMorePostedPlaylists() {
    let postedPlaylistsCoordinator = PostedPlaylistsCoordinator(navigationController, userId: userId, delegate: self)
    childCoordinators.append(postedPlaylistsCoordinator)
    postedPlaylistsCoordinator.start()
  }
}
