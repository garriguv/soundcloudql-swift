import Foundation
import UIKit

enum Cell: String {
  case Track = "TrackCollectionViewCell"
  case BigUser = "BigUserCollectionViewCell"
}

enum View: String {
  case CollectionHeader = "CollectionSectionHeader"
  case CollectionFooter = "CollectionSectionFooter"
}

protocol ReusableCell {
  var reuseIdentifier: String { get }
  func register(inCollectionView collectionView: UICollectionView?)
}

extension Cell: ReusableCell {
  var reuseIdentifier: String {
    return rawValue
  }

  func register(inCollectionView collectionView: UICollectionView?) {
    guard let collectionView = collectionView else {
      preconditionFailure("trying to register a cell (\(reuseIdentifier)) on a nil collection view")
    }
    let nib = UINib(nibName: reuseIdentifier, bundle: NSBundle.mainBundle())
    collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
  }
}

protocol ReusableView {
  var reuseIdentifier: String { get }
  func register(inCollectionView collectionView: UICollectionView?, supplementaryViewKind: String)
}

extension View: ReusableView {
  var reuseIdentifier: String {
    return rawValue
  }

  func register(inCollectionView collectionView: UICollectionView?, supplementaryViewKind: String) {
    guard let collectionView = collectionView else {
      preconditionFailure("trying to register a cell (\(reuseIdentifier)) on a nil collection view")
    }
    let nib = UINib(nibName: reuseIdentifier, bundle: NSBundle.mainBundle())
    collectionView.registerNib(nib, forSupplementaryViewOfKind: supplementaryViewKind, withReuseIdentifier: reuseIdentifier)
  }
}
