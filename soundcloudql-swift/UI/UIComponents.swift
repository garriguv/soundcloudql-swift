import Foundation
import UIKit

enum Cell: String {
  case Track = "TrackCollectionViewCell"
  case BigUser = "BigUserCollectionViewCell"
}

protocol ReusableCell {
  var reuseIdentifier: String { get }
  func register(collectionView: UICollectionView?)
}

extension Cell: ReusableCell {
  var reuseIdentifier: String {
    return rawValue
  }

  func register(collectionView: UICollectionView?) {
    guard let collectionView = collectionView else {
      preconditionFailure("trying to register a cell (\(reuseIdentifier)) on a nil collection view")
    }
    let nib = UINib(nibName: reuseIdentifier, bundle: NSBundle.mainBundle())
    collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
  }
}
