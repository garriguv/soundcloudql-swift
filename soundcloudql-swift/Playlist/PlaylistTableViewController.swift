import Foundation
import UIKit

protocol PlaylistTableViewControllerDelegate: class {
  func viewDidDisappear()

  func didTapTrack(trackId: String, permalinkUrl: String)
  func didTapUser(userId: String, permalinkUrl: String)
}

enum PlaylistSections: Int {
  case playlist = 0, user, tracks, count
}

class PlaylistTableViewController: UITableViewController {
  var playlistId: String!
  weak var playlistDelegate: PlaylistTableViewControllerDelegate?

  fileprivate var playlist: Playlist?
  fileprivate var paginating: Bool = false
}

// View lifecycle
extension PlaylistTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    let playlistResolver = GraphQLQueryResolver(query: PlaylistQuery(playlistId: playlistId))
    playlistResolver.fetch() { (response: QueryResponse<Playlist>) in
      switch response {
      case .success(let playlist):
        self.updatePlaylist(playlist)
      case .error(let error):
        print(error)
      }
    }
  }

  override func didMove(toParentViewController parent: UIViewController?) {
    if (parent == nil) {
      playlistDelegate?.viewDidDisappear()
    }
  }
}

// UITableViewDataSource
extension PlaylistTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    if playlist != nil {
      return PlaylistSections.count.rawValue
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let playlist = playlist {
      switch PlaylistSections(rawValue: section)! {
      case .playlist:
        return 1
      case .user:
        return 1
      case .tracks:
        return playlist.tracksCollection.collection.count
      default:
        preconditionFailure("invalid section \(section)")
      }
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch PlaylistSections(rawValue: indexPath.section)! {
    case .playlist:
      let cell = tableView.dequeueReusableCell(withIdentifier: BigPlaylistTableViewCell.reuseIdentifier, for: indexPath) as! BigPlaylistTableViewCell
      cell.render(playlist!)
      return cell
    case .user:
      let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseIdentifier, for: indexPath) as! UserTableViewCell
      cell.render(playlist!.userConnection)
      return cell
    case .tracks:
      let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableViewCell.reuseIdentifier, for: indexPath) as! TrackTableViewCell
      cell.render(playlist!.tracksCollection.collection[indexPath.row])
      return cell
    default:
      preconditionFailure("invalid section in indexpath \(indexPath)")
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch PlaylistSections(rawValue: section)! {
    case .tracks:
      return "\(playlist!.tracksCount) tracks (\(playlist!.tracksCollection.collection.count) loaded)"
    default:
      return nil
    }
  }
}

// UITableViewDelegate
extension PlaylistTableViewController {
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch PlaylistSections(rawValue: indexPath.section)! {
    case .playlist:
      return BigPlaylistTableViewCell.height
    case .user:
      return UserTableViewCell.height
    case .tracks:
      return TrackTableViewCell.height
    default:
      preconditionFailure("invalid section in indexpath \(indexPath)")
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    switch PlaylistSections(rawValue: indexPath.section)! {
    case .user:
      playlistDelegate?.didTapUser(userId: playlist!.userConnection.id, permalinkUrl: playlist!.userConnection.permalinkUrl)
    case .tracks:
      if let track = playlist?.tracksCollection.collection[indexPath.row] {
        playlistDelegate?.didTapTrack(trackId: track.id, permalinkUrl: track.permalinkUrl)
      }
    default:
      break
    }
  }
}

// UIScrollViewDelegate
extension PlaylistTableViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if paginationShouldBeTriggered(scrollView) {
      let playlistTracksResolver = GraphQLQueryResolver(query: PlaylistTracksQuery(id: playlist!.id, limit: 50, next: playlist!.tracksCollection.next))
      paginating = true
      playlistTracksResolver.fetch() { (response: QueryResponse<PlaylistTracks>) in
        self.paginating = false
        switch response {
        case .success(let playlistTracks):
          self.appendPlaylistTracks(playlistTracks)
        case .error(let error):
          print(error)
        }
      }
    }
  }

  fileprivate func paginationShouldBeTriggered(_ scrollView: UIScrollView) -> Bool {
    if shouldPaginate() {
      return (scrollView.contentSize.height - scrollView.frame.size.height) - scrollView.contentOffset.y < tableView.frame.size.height * 2
    } else {
      return false
    }
  }

  fileprivate func shouldPaginate() -> Bool {
    if let playlist = playlist {
      return !paginating && playlist.tracksCollection.next != nil
    }
    return false
  }
}

// Private
extension PlaylistTableViewController {
  fileprivate func setup() {
    title = "playlist"

    BigPlaylistTableViewCell.register(inTableView: tableView)
    TrackTableViewCell.register(inTableView: tableView)
    UserTableViewCell.register(inTableView: tableView)
  }

  fileprivate func updatePlaylist(_ newPlaylist: Playlist) {
    playlist = newPlaylist
    tableView.reloadData()
  }

  fileprivate func appendPlaylistTracks(_ newPlaylistTracks: PlaylistTracks) {
    let collection = playlist!.tracksCollection.collection + newPlaylistTracks.playlist.tracksCollection.collection
    let playlistTracksCollection = PlaylistTracksCollection(collection: collection, next: newPlaylistTracks.playlist.tracksCollection.next)
    playlist = Playlist(id: playlist!.id, title: playlist!.title, description: playlist!.description, artworkUrl: playlist!.artworkUrl, tracksCount: playlist!.tracksCount, userConnection: playlist!.userConnection, tracksCollection: playlistTracksCollection)
    tableView.reloadData()
  }
}
