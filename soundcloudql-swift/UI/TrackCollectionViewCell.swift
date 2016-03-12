import Foundation
import UIKit

class TrackCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var title: UILabel!

  static let height: CGFloat = 70

  func present(track: Track) {
    title.text = track.title
  }
}
