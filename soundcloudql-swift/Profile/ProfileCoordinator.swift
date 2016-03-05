import Foundation
import UIKit

class ProfileCoordinator : Coordinator {
  let navigationController: UINavigationController

  init(_ navigationController: UINavigationController) {
    self.navigationController = navigationController
  }

  func start() {
    let layout = UICollectionViewFlowLayout()
    let viewController = ProfileCollectionViewController(collectionViewLayout: layout)
    viewController.title = "Profile"
    navigationController.pushViewController(viewController, animated: false)
  }
}
