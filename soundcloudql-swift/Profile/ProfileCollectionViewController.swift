import Foundation
import UIKit

class ProfileCollectionViewController: UICollectionViewController {

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let controller = ApiController.sharedInstance
    controller.fetch(withGraphQLQuery: "profile", variables: [ "id": "2" ]) {
      (response) in
      print("\(response)")
    }
  }

}
