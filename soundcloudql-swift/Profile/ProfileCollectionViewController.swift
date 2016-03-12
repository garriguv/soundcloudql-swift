import Foundation
import UIKit

class ProfileCollectionViewController: UICollectionViewController {

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let profileResolver = GraphQLQueryResolver(query: ProfileQuery(profileID: "2"))
    profileResolver.fetch() { response in
      print(response)
    }
  }

}
