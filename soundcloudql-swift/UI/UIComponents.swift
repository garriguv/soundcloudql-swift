import Foundation
import UIKit

enum Cell: String {
  case Track = "TrackTableViewCell"
  case Playlist = "PlaylistTableViewCell"
  case BigUser = "BigUserTableViewCell"
}

protocol ReusableCell {
  var reuseIdentifier: String { get }

  func register(inTableView tableView: UITableView)
  func register(inCollectionView collectionView: UICollectionView?)
}

extension Cell: ReusableCell {
  var reuseIdentifier: String {
    return rawValue
  }

  func register(inTableView tableView: UITableView) {
    let nib = UINib(nibName: reuseIdentifier, bundle: NSBundle.mainBundle())
    tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
  }

  func register(inCollectionView collectionView: UICollectionView?) {
    guard let collectionView = collectionView else {
      preconditionFailure("trying to register a cell (\(reuseIdentifier)) on a nil collection view")
    }
    let nib = UINib(nibName: reuseIdentifier, bundle: NSBundle.mainBundle())
    collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
  }
}
