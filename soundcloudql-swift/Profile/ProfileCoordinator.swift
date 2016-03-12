import Foundation
import UIKit

class ProfileCoordinator : Coordinator {
  let navigationController: UINavigationController

  init(_ navigationController: UINavigationController) {
    self.navigationController = navigationController
  }

  func start() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Vertical
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.itemSize = CGSize(width: self.navigationController.view.frame.size.width, height: 70)
    let viewController = ProfileCollectionViewController(collectionViewLayout: layout)
    viewController.title = "Profile"
    navigationController.pushViewController(viewController, animated: false)
  }
}
