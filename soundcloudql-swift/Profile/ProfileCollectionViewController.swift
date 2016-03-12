import Foundation
import UIKit

class ProfileTableViewController: UITableViewController {
  private var profile: Profile?
}

// View lifecycle
extension ProfileTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    registerCells()

    let profileResolver = GraphQLQueryResolver(query: ProfileQuery(profileID: "2"))
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
      return 3
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let profile = profile {
      switch section {
      case 0:
        return 1
      case 1:
        return profile.user.postedTracksCollection.collection.count + 1
      case 2:
        return profile.user.likedTracksCollection.collection.count + 1
      default:
        return 0
      }
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let cell = tableView.dequeueReusableCellWithIdentifier(Cell.BigUser.reuseIdentifier, forIndexPath: indexPath) as! BigUserTableViewCell
      let user = profile!.user
      cell.present(user)
      return cell
    default:
      if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
        let cell = tableView.dequeueReusableCellWithIdentifier("FooterCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "FooterCell")
        cell.textLabel?.text = "more \(self.tableView(tableView, titleForHeaderInSection: indexPath.section)!)"
        cell.accessoryType = .DisclosureIndicator
        return cell
      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackCell") ?? UITableViewCell(style: .Subtitle, reuseIdentifier: "TrackCell")
        let track = trackAtIndexPath(indexPath)
        cell.textLabel?.text = track.title
        return cell
      }
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 1:
      return "posted tracks"
    case 2:
      return "liked tracks"
    default:
      return nil
    }
  }
}

// UITableViewDelegate
extension ProfileTableViewController {
  override func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    switch indexPath.section {
    case 0:
      return 150
    default:
      return 50
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

// Private
extension ProfileTableViewController {
  private func setupCollectionView() {
    tableView.backgroundColor = UIColor.whiteColor()
  }

  private func registerCells() {
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
    switch indexPath.section {
    case 1:
      return profile.user.postedTracksCollection.collection[indexPath.row]
    case 2:
      return profile.user.likedTracksCollection.collection[indexPath.row]
    default:
      preconditionFailure("invalid section \(indexPath.section)")
    }
  }
}
