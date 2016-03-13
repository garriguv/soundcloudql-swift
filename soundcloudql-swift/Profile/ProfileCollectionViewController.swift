import Foundation
import UIKit

enum ProfileSections: Int {
  case User = 0, Followers, Followings, PostedTracks, LikedTracks, PostedPlaylists, Count
}

protocol ProfileTableViewControllerDelegate {
  func didTapFollowers()
  func didTapFollowings()
  func didTapMorePostedTracks()
  func didTapMoreLikedTracks()
  func didTapMorePostedPlaylists()
}

class ProfileTableViewController: UITableViewController {
  var userId: String!
  var profileDelegate: ProfileTableViewControllerDelegate?

  private var profile: Profile?
}

// View lifecycle
extension ProfileTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "profile"

    setup()

    let profileResolver = GraphQLQueryResolver(query: ProfileQuery(profileID: userId))
    profileResolver.fetch() { (response: QueryResponse<Profile>) in
      switch response {
      case .Success(let profile):
        self.updateProfile(profile)
      case .Error(let error):
        print(error)
      }
    }
  }
}

// UITableViewDataSource
extension ProfileTableViewController {
  override func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
    if let profile = profile {
      return ProfileSections.Count.rawValue
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let profile = profile {
      switch ProfileSections(rawValue: section)! {
      case .PostedTracks:
        return profile.user.postedTracksCollection.collection.count + 1
      case .LikedTracks:
        return profile.user.likedTracksCollection.collection.count + 1
      case .PostedPlaylists:
        return profile.user.postedPlaylistsCollection.collection.count + 1
      default:
        return 1
      }
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch ProfileSections(rawValue: indexPath.section)! {
    case .User:
      let cell = tableView.dequeueReusableCellWithIdentifier(Cell.BigUser.reuseIdentifier, forIndexPath: indexPath) as! BigUserTableViewCell
      let user = profile!.user
      cell.present(user)
      return cell
    case .Followers:
      let cell = tableView.dequeueReusableCellWithIdentifier("FooterCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "FooterCell")
      cell.textLabel?.text = "\(profile!.user.followersCount) followers"
      cell.accessoryType = .DisclosureIndicator
      return cell
    case .Followings:
      let cell = tableView.dequeueReusableCellWithIdentifier("FooterCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "FooterCell")
      cell.textLabel?.text = "\(profile!.user.followingsCount) followings"
      cell.accessoryType = .DisclosureIndicator
      return cell
    case .PostedTracks, .LikedTracks:
      if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
        let cell = tableView.dequeueReusableCellWithIdentifier("FooterCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "FooterCell")
        cell.textLabel?.text = "more \(self.tableView(tableView, titleForHeaderInSection: indexPath.section)!)"
        cell.accessoryType = .DisclosureIndicator
        return cell
      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier(Cell.Track.reuseIdentifier, forIndexPath: indexPath) as! TrackTableViewCell
        let track = trackAtIndexPath(indexPath)
        cell.present(track)
        return cell
      }
    case .PostedPlaylists:
      if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
        let cell = tableView.dequeueReusableCellWithIdentifier("FooterCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "FooterCell")
        cell.textLabel?.text = "more \(self.tableView(tableView, titleForHeaderInSection: indexPath.section)!)"
        cell.accessoryType = .DisclosureIndicator
        return cell
      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier(Cell.Playlist.reuseIdentifier, forIndexPath: indexPath) as! PlaylistTableViewCell
        let playlist = playlistAtIndexPath(indexPath)
        cell.present(playlist)
        return cell
      }
    default:
      preconditionFailure("\(__FUNCTION__) invalid section \(indexPath.section)")
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch ProfileSections(rawValue: section)! {
    case .PostedTracks:
      return "posted tracks"
    case .LikedTracks:
      return "liked tracks"
    case .PostedPlaylists:
      return "posted playlists"
    default:
      return nil
    }
  }
}

// UITableViewDelegate
extension ProfileTableViewController {
  override func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    switch ProfileSections(rawValue: indexPath.section)! {
    case .User:
      return BigUserTableViewCell.height
    case .PostedPlaylists:
       return PlaylistTableViewCell.height
    default:
      return TrackTableViewCell.height
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    switch ProfileSections(rawValue: indexPath.section)! {
    case .Followers:
      profileDelegate?.didTapFollowers()
    case .Followings:
      profileDelegate?.didTapFollowings()
    case .PostedTracks:
      if (indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1) {
        profileDelegate?.didTapMorePostedTracks()
      }
    case .LikedTracks:
      if (indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1) {
        profileDelegate?.didTapMoreLikedTracks()
      }
    case .PostedPlaylists:
      if (indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1) {
        profileDelegate?.didTapMorePostedPlaylists()
      }
    default:
      break
    }
  }
}

// Private
extension ProfileTableViewController {
  private func setupCollectionView() {
    tableView.backgroundColor = UIColor.whiteColor()
  }

  private func setup() {
    title = "profile"

    Cell.Track.register(inTableView: tableView)
    Cell.Playlist.register(inTableView: tableView)
    Cell.BigUser.register(inTableView: tableView)
  }

  private func updateProfile(newProfile: Profile) {
    profile = newProfile
    tableView.reloadData()
  }

  private func trackAtIndexPath(indexPath: NSIndexPath) -> Track {
    guard let profile = profile else {
      preconditionFailure("trying to access a track (\(indexPath)) without a profile")
    }
    switch ProfileSections(rawValue: indexPath.section)! {
    case .PostedTracks:
      return profile.user.postedTracksCollection.collection[indexPath.row]
    case .LikedTracks:
      return profile.user.likedTracksCollection.collection[indexPath.row]
    default:
      preconditionFailure("invalid section \(indexPath.section)")
    }
  }

  private func playlistAtIndexPath(indexPath: NSIndexPath) -> Playlist {
    guard let profile = profile else {
      preconditionFailure("trying to access a track (\(indexPath)) without a profile")
    }
    switch ProfileSections(rawValue: indexPath.section)! {
    case .PostedPlaylists:
      return profile.user.postedPlaylistsCollection.collection[indexPath.row]
    default:
      preconditionFailure("invalid section \(indexPath.section)")
    }
  }
}
