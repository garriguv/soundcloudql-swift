import Foundation
import UIKit

protocol PlaylistTableViewControllerDelegate: class {
}

class PlaylistTableViewController: UITableViewController {
  var playlistId: String!
  weak var playlistDelegate: PlaylistTableViewControllerDelegate?

  private var playlist: Playlist?
}
