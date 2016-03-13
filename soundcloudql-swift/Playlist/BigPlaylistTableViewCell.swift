import Foundation
import UIKit
import Kingfisher

protocol BigPlaylistRenderable {
  var title: String { get }
  var artworkUrl: String? { get }
}

class BigPlaylistTableViewCell: UITableViewCell {
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
}

extension BigPlaylistTableViewCell: RenderableCell {
  @nonobjc static let height: CGFloat = 150

  func render(object: GraphQLObject) {
    if let playlist = object as? BigPlaylistRenderable {
      titleLabel.text = playlist.title
      if let artworkUrl = playlist.artworkUrl, artworkURL = NSURL(string: artworkUrl) {
        artworkImageView.kf_setImageWithURL(artworkURL)
      }
    }
  }
}
