import Foundation
import UIKit
import Kingfisher

class TrackTableViewCell: UITableViewCell {
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
}

extension TrackTableViewCell: RenderableCell {
  @nonobjc static let height: CGFloat = 50

  func render(object: GraphQLObject) {
    if let track = object as? Track {
      titleLabel.text = track.title
      if let artworkUrl = track.artworkUrl {
        artworkImageView.kf_setImageWithURL(NSURL(string: artworkUrl)!)
      } else {
        artworkImageView.image = nil
      }
    }
  }
}


