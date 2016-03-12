import Foundation
import UIKit

class BigUserCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var cityLabel: UILabel!

  static let height: CGFloat = 150

  func present(user: User) {
    usernameLabel.text = user.username
    cityLabel.text = user.city
  }
}
