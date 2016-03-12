import Foundation
import UIKit

protocol GraphQLCollectionEngine {
  weak var tableView: UITableView? { get set }

  func initialFetch()

  func paginate()

  func numberOfItems() -> Int

  func itemAtIndexPath(indexPath: NSIndexPath) -> Track

  func shouldPaginate() -> Bool
}

class GraphQLCollectionEngineDelegate<Query:GraphQLCollectionQuery, Collection:GraphQLCollectionObject>: GraphQLCollectionEngine {

  let userId: String

  init(userId: String) {
    self.userId = userId
  }

  var collection: Collection?
  var paginating: Bool = false
  weak var tableView: UITableView?

  func initialFetch() {
    let queryResolver = GraphQLQueryResolver(query: Query(userId: userId, limit: 50, next: nil))
    queryResolver.fetch() {
      response in
      switch response {
      case .Success(let collection):
        self.updateCollection(collection)
      case .Error(let error):
        print(error)
      }
    }
  }

  func paginate() {
    guard let collection = collection else {
      preconditionFailure("trying to paginate without a collection")
    }
    paginating = true
    let query = Query(userId: userId, limit: 50, next: collection.next())
    let nextPageResolver = GraphQLQueryResolver(query: query)
    nextPageResolver.fetch() {
      (response: QueryResponse<Query.Object>) in
      switch response {
      case .Success(let collection):
        self.appendObjects(collection)
      case .Error(let error):
        print(error)
      }
      self.paginating = false
    }
  }

  func numberOfItems() -> Int {
    if let collection = collection {
      return collection.numberOfItems()
    }
    return 0
  }

  func itemAtIndexPath(indexPath: NSIndexPath) -> Track {
    guard let collection = collection else {
      preconditionFailure("trying to access a track (\(indexPath)) without a collection")
    }
    return collection.itemAtIndexPath(indexPath)
  }

  func shouldPaginate() -> Bool {
    return collection != nil && !paginating && collection?.next() != nil
  }

  private func updateCollection(newCollection: Query.Object) {
    collection = newCollection as! Collection
    tableView?.reloadData()
  }

  private func appendObjects(newCollection: Query.Object) {
    guard let _collection = collection else {
      preconditionFailure("Trying to paginate before having any tracks")
    }
    collection = _collection.appendObjects(newCollection as! Collection)
    tableView?.reloadData()
  }
}

protocol CollectionTableViewControllerDelegate {
  func viewDidDisappear()
}

class CollectionTableViewController: UITableViewController {
  var collectionEngine: GraphQLCollectionEngine!

  var collectionDelegate: CollectionTableViewControllerDelegate?

  private var paginating: Bool = false
}

// View lifecycle

extension CollectionTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    collectionEngine.tableView = tableView
    collectionEngine.initialFetch()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    collectionDelegate?.viewDidDisappear()
  }
}

// UITableViewDataSource

extension CollectionTableViewController {
  override func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collectionEngine.numberOfItems()
  }

  override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Cell.Track.reuseIdentifier, forIndexPath: indexPath) as! TrackTableViewCell
    let track = collectionEngine.itemAtIndexPath(indexPath)
    cell.present(track)
    return cell
  }
}

// UITableViewDelegate

extension CollectionTableViewController {
  override func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return TrackTableViewCell.height
  }

  override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

// UIScrollViewDelegate

extension CollectionTableViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if paginationShouldBeTriggered(scrollView) {
      collectionEngine.paginate()
    }
  }

  private func paginationShouldBeTriggered(scrollView: UIScrollView) -> Bool {
    if collectionEngine.shouldPaginate() {
      return (scrollView.contentSize.height - scrollView.frame.size.height) - scrollView.contentOffset.y < tableView.frame.size.height * 2
    } else {
      return false
    }
  }
}

// Private

extension CollectionTableViewController {
  private func setup() {
    Cell.Track.register(inTableView: tableView)
  }
}

