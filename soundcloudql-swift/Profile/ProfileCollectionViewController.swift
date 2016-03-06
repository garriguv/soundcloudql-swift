import Foundation
import UIKit

class ProfileCollectionViewController: UICollectionViewController {

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let controller = ApiController.sharedInstance
    controller.fetch(withGraphQLQuery: "profile", variables: [ "id": "2" ]) {
      (json: [String: AnyObject]?, error: ApiControllerError?) in
      print("json \(json)")
      print("error \(error)")
    }
  }

}
