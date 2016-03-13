import Foundation
import UIKit

protocol PlaylistTableViewControllerDelegate: class {
  func viewDidDisappear()
}

enum PlaylistSections: Int {
  case Playlist = 0, User, Tracks, Count
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

  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)

    playlistDelegate?.viewDidDisappear()
  }
}

// UITableViewDataSource
extension PlaylistTableViewController {
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if playlist != nil {
      return PlaylistSections.Count.rawValue
    }
    return 0
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let playlist = playlist {
      switch PlaylistSections(rawValue: section)! {
      case .Playlist:
        return 1
      case .User:
        return 1
      case .Tracks:
        return playlist.tracksCollection.collection.count
      default:
        preconditionFailure("invalid section \(section)")
      }
    }
    return 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch PlaylistSections(rawValue: indexPath.section)! {
    case .Playlist:
      let cell = tableView.dequeueReusableCellWithIdentifier(BigPlaylistTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! BigPlaylistTableViewCell
      cell.render(playlist!)
      return cell
    case .User:
      let cell = tableView.dequeueReusableCellWithIdentifier(UserTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! UserTableViewCell
      cell.render(playlist!.userConnection)
      return cell
    case .Tracks:
      let cell = tableView.dequeueReusableCellWithIdentifier(TrackTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! TrackTableViewCell
      cell.render(playlist!.tracksCollection.collection[indexPath.row])
      return cell
    default:
      preconditionFailure("invalid section in indexpath \(indexPath)")
    }
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch PlaylistSections(rawValue: section)! {
    case .Tracks:
      return "\(playlist!.tracksCollection.collection.count) tracks"
    default:
      return nil
    }
  }
}

// UITableViewDelegate
extension PlaylistTableViewController {
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    switch PlaylistSections(rawValue: indexPath.section)! {
      case .Playlist:
        return BigPlaylistTableViewCell.height
      case .User:
        return UserTableViewCell.height
      case .Tracks:
        return TrackTableViewCell.height
      default:
        preconditionFailure("invalid section in indexpath \(indexPath)")
    }
    return 0
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
