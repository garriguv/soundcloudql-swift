import Foundation
import UIKit

enum ProfileSections: Int {
  case user = 0, followers, followings, postedTracks, likedTracks, postedPlaylists, count
}

protocol ProfileTableViewControllerDelegate {
  func viewDidDisappear()

  func didTapFollowers()
  func didTapFollowings()
  func didTapMorePostedTracks()
  func didTapMoreLikedTracks()
  func didTapMorePostedPlaylists()

  func didTapTrack(trackId: String, permalinkUrl: String)
  func didTapPlaylist(playlistId: String, permalinkUrl: String)
}

class ProfileTableViewController: UITableViewController {
  var userId: String!
  var profileDelegate: ProfileTableViewControllerDelegate?

  fileprivate var profile: Profile?
}

// View lifecycle
extension ProfileTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    let profileResolver = GraphQLQueryResolver(query: ProfileQuery(profileId: userId))
    profileResolver.fetch() { (response: QueryResponse<Profile>) in
      switch response {
      case .success(let profile):
        self.updateProfile(profile)
      case .error(let error):
        print(error)
      }
    }
  }
}

// UITableViewDataSource
extension ProfileTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    if let _ = profile {
      return ProfileSections.count.rawValue
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let profile = profile {
      switch ProfileSections(rawValue: section)! {
      case .postedTracks:
        return profile.user.postedTracksCollection.collection.count + 1
      case .likedTracks:
        return profile.user.likedTracksCollection.collection.count + 1
      case .postedPlaylists:
        return profile.user.postedPlaylistsCollection.collection.count + 1
      default:
        return 1
      }
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch ProfileSections(rawValue: indexPath.section)! {
    case .user:
      let cell = tableView.dequeueReusableCell(withIdentifier: BigUserTableViewCell.reuseIdentifier, for: indexPath) as! BigUserTableViewCell
      let user = profile!.user
      cell.render(user)
      return cell
    case .followers:
      let cell = tableView.dequeueReusableCell(withIdentifier: "FooterCell") ?? UITableViewCell(style: .default, reuseIdentifier: "FooterCell")
      cell.textLabel?.text = "\(profile!.user.followersCount) followers"
      cell.accessoryType = .disclosureIndicator
      return cell
    case .followings:
      let cell = tableView.dequeueReusableCell(withIdentifier: "FooterCell") ?? UITableViewCell(style: .default, reuseIdentifier: "FooterCell")
      cell.textLabel?.text = "\(profile!.user.followingsCount) followings"
      cell.accessoryType = .disclosureIndicator
      return cell
    case .postedTracks, .likedTracks:
      if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FooterCell") ?? UITableViewCell(style: .default, reuseIdentifier: "FooterCell")
        cell.textLabel?.text = "more \(self.tableView(tableView, titleForHeaderInSection: indexPath.section)!)"
        cell.accessoryType = .disclosureIndicator
        return cell
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableViewCell.reuseIdentifier, for: indexPath) as! TrackTableViewCell
        let track = trackAtIndexPath(indexPath)
        cell.render(track)
        return cell
      }
    case .postedPlaylists:
      if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FooterCell") ?? UITableViewCell(style: .default, reuseIdentifier: "FooterCell")
        cell.textLabel?.text = "more \(self.tableView(tableView, titleForHeaderInSection: indexPath.section)!)"
        cell.accessoryType = .disclosureIndicator
        return cell
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistTableViewCell.reuseIdentifier, for: indexPath) as! PlaylistTableViewCell
        let playlist = playlistAtIndexPath(indexPath)
        cell.render(playlist)
        return cell
      }
    default:
      preconditionFailure("\(#function) invalid section \(indexPath.section)")
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch ProfileSections(rawValue: section)! {
    case .postedTracks:
      return "posted tracks"
    case .likedTracks:
      return "liked tracks"
    case .postedPlaylists:
      return "posted playlists"
    default:
      return nil
    }
  }
}

// UITableViewDelegate
extension ProfileTableViewController {
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch ProfileSections(rawValue: indexPath.section)! {
    case .user:
      return BigUserTableViewCell.height
    case .postedPlaylists:
       return PlaylistTableViewCell.height
    default:
      return TrackTableViewCell.height
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    switch ProfileSections(rawValue: indexPath.section)! {
    case .followers:
      profileDelegate?.didTapFollowers()
    case .followings:
      profileDelegate?.didTapFollowings()
    case .postedTracks:
      if (indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1) {
        profileDelegate?.didTapMorePostedTracks()
      } else {
        let track = trackAtIndexPath(indexPath)
        profileDelegate?.didTapTrack(trackId: track.id, permalinkUrl: track.permalinkUrl)
      }
    case .likedTracks:
      if (indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1) {
        profileDelegate?.didTapMoreLikedTracks()
      } else {
        let track = trackAtIndexPath(indexPath)
        profileDelegate?.didTapTrack(trackId: track.id, permalinkUrl: track.permalinkUrl)
      }
    case .postedPlaylists:
      if (indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1) {
        profileDelegate?.didTapMorePostedPlaylists()
      } else {
        let playlist = playlistAtIndexPath(indexPath)
        profileDelegate?.didTapPlaylist(playlistId: playlist.id, permalinkUrl: playlist.permalinkUrl)
      }
    default:
      break
    }
  }
}

// Private
extension ProfileTableViewController {
  fileprivate func setup() {
    title = "profile"

    TrackTableViewCell.register(inTableView: tableView)
    PlaylistTableViewCell.register(inTableView: tableView)
    BigUserTableViewCell.register(inTableView: tableView)
  }

  fileprivate func updateProfile(_ newProfile: Profile) {
    profile = newProfile
    tableView.reloadData()
  }

  fileprivate func trackAtIndexPath(_ indexPath: IndexPath) -> Track {
    guard let profile = profile else {
      preconditionFailure("trying to access a track (\(indexPath)) without a profile")
    }
    switch ProfileSections(rawValue: indexPath.section)! {
    case .postedTracks:
      return profile.user.postedTracksCollection.collection[indexPath.row]
    case .likedTracks:
      return profile.user.likedTracksCollection.collection[indexPath.row]
    default:
      preconditionFailure("invalid section \(indexPath.section)")
    }
  }

  fileprivate func playlistAtIndexPath(_ indexPath: IndexPath) -> MiniPlaylist {
    guard let profile = profile else {
      preconditionFailure("trying to access a track (\(indexPath)) without a profile")
    }
    switch ProfileSections(rawValue: indexPath.section)! {
    case .postedPlaylists:
      return profile.user.postedPlaylistsCollection.collection[indexPath.row]
    default:
      preconditionFailure("invalid section \(indexPath.section)")
    }
  }
}
