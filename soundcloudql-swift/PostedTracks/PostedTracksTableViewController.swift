import Foundation
import UIKit

class PostedTracksTableViewController: UITableViewController {
  var userId: String!
  private var postedTracks: PostedTracks?
}

// View lifecycle
extension PostedTracksTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    let postedTracksResolver = GraphQLQueryResolver(query: PostedTracksQuery(profileID: userId))
    postedTracksResolver.fetch() { (response: QueryResponse<PostedTracks>) in
      switch response {
      case .Success(let collection):
        self.updatePostedTracks(collection)
      case .Error(let error):
        print(error)
      }
    }
  }
}

// UITableViewDataSource
extension PostedTracksTableViewController {
  override func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let postedTracks = postedTracks {
      return postedTracks.user.postedTracksCollection.collection.count
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Cell.Track.reuseIdentifier, forIndexPath: indexPath) as! TrackTableViewCell
    let track = trackAtIndexPath(indexPath)
    cell.present(track)
    return cell
  }
}

// UITableViewDelegate
extension PostedTracksTableViewController {
  override func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return TrackTableViewCell.height
  }

  override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

// UIScrollViewDelegate
extension PostedTracksTableViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
  }
}

// Private
extension PostedTracksTableViewController {
  private func setup() {
    title = "posted tracks"

    Cell.Track.register(inTableView: tableView)
  }

  private func updatePostedTracks(newCollection: PostedTracks) {
    postedTracks = newCollection
    tableView.reloadData()
  }

  private func trackAtIndexPath(indexPath: NSIndexPath) -> Track {
    guard let postedTracksCollection = postedTracks else {
      preconditionFailure("trying to access a track (\(indexPath)) without a profile")
    }
    return postedTracksCollection.user.postedTracksCollection.collection[indexPath.row]
  }
}
