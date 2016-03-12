import Foundation
import UIKit

class ProfileCollectionViewController: UICollectionViewController {
  private var profile: Profile?
}

// View lifecycle
extension ProfileCollectionViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    setupCollectionView()
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

// UICollectionViewDataSource
extension ProfileCollectionViewController {
  override func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int {
    if let profile = profile {
      return 3
    }
    return 0
  }

  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let profile = profile {
      switch section {
      case 0:
        return 1
      case 1:
        return profile.user.postedTracksCollection.collection.count
      case 2:
        return profile.user.likedTracksCollection.collection.count
      default:
        return 0
      }
    }
    return 0
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    switch indexPath.section {
    case 0:
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.BigUser.reuseIdentifier, forIndexPath: indexPath) as! BigUserCollectionViewCell
      let user = profile!.user
      cell.present(user)
      return cell
    default:
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.Track.reuseIdentifier, forIndexPath: indexPath) as! TrackCollectionViewCell
      let track = trackAtIndexPath(indexPath)
      cell.present(track)
      return cell
    }
  }

  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: View.CollectionHeader.reuseIdentifier, forIndexPath: indexPath) as! CollectionSectionHeader
      view.present(sectionHeaderTitle(indexPath.section))
      return view
    case UICollectionElementKindSectionFooter:
      let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: View.CollectionFooter.reuseIdentifier, forIndexPath: indexPath) as! CollectionSectionFooter
      view.present(sectionFooterMessage(indexPath.section))
      return view
    default:
      preconditionFailure("Unknown supplementary view kind \(kind)")
    }
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

// UICollectionViewDelegateFlowLayout
extension ProfileCollectionViewController {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    switch indexPath.section {
    case 0:
      return CGSize(width: collectionView.frame.width, height: BigUserCollectionViewCell.height)
    default:
      return CGSize(width: collectionView.frame.width, height: TrackCollectionViewCell.height)
    }
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return section == 0 ? CGSize.zero : CGSize(width: collectionView.frame.width, height: CollectionSectionHeader.height)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return section == 0 ? CGSize.zero : CGSize(width: collectionView.frame.width, height: CollectionSectionFooter.height)
  }
}

// Private
extension ProfileCollectionViewController {
  private func setupCollectionView() {
    collectionView?.backgroundColor = UIColor.whiteColor()
  }

  private func registerCells() {
    Cell.Track.register(inCollectionView: collectionView)
    Cell.BigUser.register(inCollectionView: collectionView)
    View.CollectionHeader.register(inCollectionView: collectionView, supplementaryViewKind: UICollectionElementKindSectionHeader)
    View.CollectionFooter.register(inCollectionView: collectionView, supplementaryViewKind: UICollectionElementKindSectionFooter)
  }

  private func updateProfile(newProfile: Profile) {
    profile = newProfile
    collectionView?.reloadData()
  }

  private func sectionHeaderTitle(section: Int) -> String {
    switch section {
    case 1:
      return "posted tracks"
    case 2:
      return "liked tracks"
    default:
      preconditionFailure("missing title for section \(section)")
    }
  }

  private func sectionFooterMessage(section: Int) -> String {
    switch section {
    case 1:
      return "more posted tracks >"
    case 2:
      return "more liked tracks >"
    default:
      preconditionFailure("missing title for section \(section)")
    }
  }
}
