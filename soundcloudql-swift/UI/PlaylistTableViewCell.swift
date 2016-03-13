import Foundation
import UIKit

protocol PlaylistRenderable {
  var id: String { get }
  var title: String { get }
  var tracksCount: Int { get }
  var artworkUrl: String? { get }
}

class PlaylistTableViewCell: UITableViewCell {
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var tracksCountLabel: UILabel!
}

extension PlaylistTableViewCell: RenderableCell {
  @nonobjc static let height: CGFloat = 70

  func render(object: GraphQLObject) {
    if let playlist = object as? PlaylistRenderable {
      titleLabel.text = playlist.title
      tracksCountLabel.text = "\(playlist.tracksCount) tracks"
      if let artworkUrl = playlist.artworkUrl, let artworkURL = NSURL(string: artworkUrl) {
        artworkImageView.kf_setImageWithURL(artworkURL)
      } else {
        artworkImageView.image = nil
      }
    }
  }
}
