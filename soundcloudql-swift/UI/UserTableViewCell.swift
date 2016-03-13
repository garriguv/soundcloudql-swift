import Foundation
import UIKit
import Kingfisher

protocol UserRenderable {
  var username: String { get }
  var avatarUrl: String? { get }
}

class UserTableViewCell: UITableViewCell {
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
}

extension UserTableViewCell: RenderableCell {
  @nonobjc static let height: CGFloat = 50

  func render(object: GraphQLObject) {
    if let user = object as? UserRenderable {
      usernameLabel.text = user.username
      if let avatarUrl = user.avatarUrl, let avatarURL = NSURL(string: avatarUrl) {
        avatarImageView.kf_setImageWithURL(avatarURL)
      } else {
        avatarImageView.image = nil
      }
    }
  }
}
