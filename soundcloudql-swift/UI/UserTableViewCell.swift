import Foundation
import UIKit
import Kingfisher

protocol UserRenderable {
  var id: String { get }
  var username: String { get }
  var avatarUrl: String? { get }
}

class UserTableViewCell: UITableViewCell {
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
}

extension UserTableViewCell: RenderableCell {
  @nonobjc static let height: CGFloat = 50

  func render(_ object: GraphQLObject) {
    if let user = object as? UserRenderable {
      usernameLabel.text = user.username
      if let avatarUrl = user.avatarUrl, let avatarURL = URL(string: avatarUrl) {
        avatarImageView.kf.setImage(with: avatarURL)
      } else {
        avatarImageView.image = nil
      }
    }
  }
}
