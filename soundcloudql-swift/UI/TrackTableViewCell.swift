import Foundation
import UIKit
import Kingfisher

protocol TrackRenderable {
  var permalinkUrl: String { get }
  var title: String { get }
  var artworkUrl: String? { get }
}

class TrackTableViewCell: UITableViewCell {
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
}

extension TrackTableViewCell: RenderableCell {
  @nonobjc static let height: CGFloat = 50

  func render(_ object: GraphQLObject) {
    if let track = object as? TrackRenderable {
      titleLabel.text = track.title
      if let artworkUrl = track.artworkUrl {
        artworkImageView.kf.setImage(with: URL(string: artworkUrl)!)
      } else {
        artworkImageView.image = nil
      }
    }
  }
}


