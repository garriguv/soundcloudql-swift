import Foundation
import UIKit

protocol PlaylistTableViewControllerDelegate: class {
  func viewDidDisappear()

  func didTapTrack(trackId trackId: String, permalinkUrl: String)
  func didTapUser(userId userId: String, permalinkUrl: String)
}

enum PlaylistSections: Int {
  case Playlist = 0, User, Tracks, Count
}

class PlaylistTableViewController: UITableViewController {
  var playlistId: String!
  weak var playlistDelegate: PlaylistTableViewControllerDelegate?

  private var playlist: Playlist?
  private var paginating: Bool = false
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

  override func didMoveToParentViewController(parent: UIViewController?) {
    if (parent == nil) {
      playlistDelegate?.viewDidDisappear()
    }
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
      return "\(playlist!.tracksCount) tracks (\(playlist!.tracksCollection.collection.count) loaded)"
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
    switch PlaylistSections(rawValue: indexPath.section)! {
    case .User:
      playlistDelegate?.didTapUser(userId: playlist!.userConnection.id, permalinkUrl: playlist!.userConnection.permalinkUrl)
    case .Tracks:
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
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    if paginationShouldBeTriggered(scrollView) {
      let playlistTracksResolver = GraphQLQueryResolver(query: PlaylistTracksQuery(id: playlist!.id, limit: 50, next: playlist!.tracksCollection.next))
      paginating = true
      playlistTracksResolver.fetch() { (response: QueryResponse<PlaylistTracks>) in
        self.paginating = false
        switch response {
        case .Success(let playlistTracks):
          self.appendPlaylistTracks(playlistTracks)
        case .Error(let error):
          print(error)
        }
      }
    }
  }

  private func paginationShouldBeTriggered(scrollView: UIScrollView) -> Bool {
    if shouldPaginate() {
      return (scrollView.contentSize.height - scrollView.frame.size.height) - scrollView.contentOffset.y < tableView.frame.size.height * 2
    } else {
      return false
    }
  }

  private func shouldPaginate() -> Bool {
    if let playlist = playlist {
      return !paginating && playlist.tracksCollection.next != nil
    }
    return false
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

  private func appendPlaylistTracks(newPlaylistTracks: PlaylistTracks) {
    let collection = playlist!.tracksCollection.collection + newPlaylistTracks.playlist.tracksCollection.collection
    let playlistTracksCollection = PlaylistTracksCollection(collection: collection, next: newPlaylistTracks.playlist.tracksCollection.next)
    playlist = Playlist(id: playlist!.id, title: playlist!.title, description: playlist!.description, artworkUrl: playlist!.artworkUrl, tracksCount: playlist!.tracksCount, userConnection: playlist!.userConnection, tracksCollection: playlistTracksCollection)
    tableView.reloadData()
  }
}
