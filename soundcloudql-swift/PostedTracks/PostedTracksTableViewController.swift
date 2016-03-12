import Foundation
import UIKit

class PostedTracksTableViewController: UITableViewController {
  var userId: String!

  private var postedTracks: PostedTracks?
  private var paginating: Bool = false
}

// View lifecycle
extension PostedTracksTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    let postedTracksResolver = GraphQLQueryResolver(query: PostedTracksQuery(profileID: userId, limit: 50))
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
    if let postedTracks = postedTracks where paginationShouldBeTriggered(scrollView) {
      paginating = true
      let query = PostedTracksQuery(profileID: userId, limit: 50, next: postedTracks.user.postedTracksCollection.next)
      let nextPageResolver = GraphQLQueryResolver(query: query)
      nextPageResolver.fetch() { (response: QueryResponse<PostedTracks>) in
        switch response {
        case .Success(let collection):
          self.appendPostedTracks(collection)
        case .Error(let error):
          print(error)
        }
        self.paginating = false
      }
    }
  }

  private func paginationShouldBeTriggered(scrollView: UIScrollView) -> Bool {
    if let postedTracks = postedTracks where postedTracks.user.postedTracksCollection.next != nil && !self.paginating {
      return (scrollView.contentSize.height - scrollView.frame.size.height) - scrollView.contentOffset.y < tableView.frame.size.height
    } else {
      return false
    }
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

  private func appendPostedTracks(newCollection: PostedTracks) {
    guard let _postedTracks = postedTracks else {
      preconditionFailure("Trying to paginate before having any tracks")
    }
    let tracksCollection = _postedTracks.user.postedTracksCollection.collection + newCollection.user.postedTracksCollection.collection
    let collection = UserPostedTracksCollection(collection: tracksCollection, next: newCollection.user.postedTracksCollection.next)
    let user = PostedTracksUser(postedTracksCollection: collection)
    postedTracks = PostedTracks(user: user)
    tableView.reloadData()
  }

  private func trackAtIndexPath(indexPath: NSIndexPath) -> Track {
    guard let postedTracks = postedTracks else {
      preconditionFailure("trying to access a track (\(indexPath)) without a profile")
    }
    return postedTracks.user.postedTracksCollection.collection[indexPath.row]
  }
}
