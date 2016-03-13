import Foundation
import UIKit

protocol PlaylistTableViewControllerDelegate: class {
}

class PlaylistTableViewController: UITableViewController {
  var playlistId: String!
  weak var playlistDelegate: PlaylistTableViewControllerDelegate?

  private var playlist: Playlist?
}

// View lifecycle
extension PlaylistTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    let playlistResolver = GraphQLQueryResolver(query: PlaylistQuery(playlistId: playlistId))
    playlistResolver.fetch() { (response: QueryResponse<Playlist>) in
      switch response {
      case .Success(let playlist):
        self.updatePlaylist(playlist)
      case .Error(let error):
        print(error)
      }
    }
  }
}

// Private
extension PlaylistTableViewController {
  private func setup() {
    title = "playlist"

    BigPlaylistTableViewCell.register(inTableView: tableView)
    TrackTableViewCell.register(inTableView: tableView)
    UserTableViewCell.register(inTableView: tableView)
  }

  private func updatePlaylist(newPlaylist: Playlist) {
    playlist = newPlaylist
    tableView.reloadData()
  }
}
