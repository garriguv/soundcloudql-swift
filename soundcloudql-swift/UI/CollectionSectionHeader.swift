import Foundation
import UIKit

class CollectionSectionHeader: UICollectionReusableView {
  static let height: CGFloat = 40

  @IBOutlet weak var titleLabel: UILabel!

  func present(title: String) {
    titleLabel.text = title
  }
}
