import Foundation
import UIKit

class BigUserTableViewCell: UITableViewCell {
  @IBOutlet weak var userArtworkImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var cityLabel: UILabel!

  static let height: CGFloat = 150

  func present(user: User) {
    usernameLabel.text = user.username
    cityLabel.text = user.city
  }
}
