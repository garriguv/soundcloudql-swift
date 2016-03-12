import Foundation
import UIKit

class CollectionSectionFooter: UICollectionReusableView {
  static let height: CGFloat = 50

  @IBOutlet weak var messageLabel: UILabel!

  func present(message: String) {
    messageLabel.text = message
  }
}
