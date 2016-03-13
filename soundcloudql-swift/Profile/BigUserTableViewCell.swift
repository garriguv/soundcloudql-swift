import Foundation
import UIKit
import Kingfisher

class BigUserTableViewCell: UITableViewCell {
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var cityLabel: UILabel!
}

extension BigUserTableViewCell: RenderableCell {
  @nonobjc static let height: CGFloat = 150

  func render(object: GraphQLObject) {
    if let user = object as? User {
      usernameLabel.text = user.username
      cityLabel.text = user.city
      if let avatarUrl = user.avatarUrl, avatarURL = NSURL(string: avatarUrl) {
        avatarImageView.kf_setImageWithURL(avatarURL)
      } else {
        avatarImageView.image = nil
      }
    }
  }
}
