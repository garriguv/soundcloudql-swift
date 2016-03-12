import Foundation
import UIKit
import Kingfisher

class BigUserTableViewCell: UITableViewCell {
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var cityLabel: UILabel!

  static let height: CGFloat = 150

  func present(user: User) {
    usernameLabel.text = user.username
    cityLabel.text = user.city
    if let avatarUrl = user.avatarUrl {
      avatarImageView.kf_setImageWithURL(NSURL(string: avatarUrl)!)
    }
  }
}
