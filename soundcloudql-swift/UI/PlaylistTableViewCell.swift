import Foundation
import UIKit

class PlaylistTableViewCell: UITableViewCell {
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var tracksCountLabel: UILabel!
}

extension PlaylistTableViewCell: RenderableCell {
  @nonobjc static let height: CGFloat = 70

  func render(object: GraphQLObject) {
    if let playlist = object as? MiniPlaylist {
      titleLabel.text = playlist.title
      tracksCountLabel.text = "\(playlist.tracksCount) tracks"
      if let artworkUrl = playlist.artworkUrl {
        artworkImageView.kf_setImageWithURL(NSURL(string: artworkUrl)!)
      } else {
        artworkImageView.image = nil
      }
    }
  }
}
