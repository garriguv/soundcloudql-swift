import Foundation
import UIKit

protocol Coordinator: class {
  var delegate: CoordinatorDelegate? { get set }
  var childCoordinators: [Coordinator] { get set }

  func start()
}

protocol CoordinatorDelegate: class {
  func didFinishCoordinating(coordinator: Coordinator)
}

extension Coordinator {
  func didFinishCoordinating(coordinator: Coordinator) {
    let index = childCoordinators.indexOf { $0 === coordinator }!
    childCoordinators.removeAtIndex(index)
  }
}

extension Coordinator where Self: CollectionTableViewControllerDelegate, Self: CoordinatorDelegate {
  func viewDidDisappear() {
    delegate?.didFinishCoordinating(self)
  }

  func didSelectObject(object: GraphQLObject) {
    guard let navigationController = topNavigationController() else {
      preconditionFailure("Something's weird here")
    }
    if let track = object as? TrackRenderable {
    } else if let user = object as? UserRenderable {
      let profileCoordinator = ProfileCoordinator(navigationController, userId: user.id, delegate: self)
      childCoordinators.append(profileCoordinator)
      profileCoordinator.start()
    } else if let playlist = object as? PlaylistRenderable {
      let playlistCoordinator = PlaylistCoordinator(navigationController, playlistId: playlist.id, delegate: self)
      childCoordinators.append(playlistCoordinator)
      playlistCoordinator.start()
    }
  }

  private func topNavigationController() -> UINavigationController? {
    let tabBarController = UIApplication.sharedApplication().keyWindow?.rootViewController as? UITabBarController
    return tabBarController?.viewControllers?.first as? UINavigationController
  }
}
