import Foundation
import UIKit

protocol GraphQLCollectionEngine {
  weak var tableView: UITableView? { get set }

  func setup()

  func initialFetch()

  func paginate()

  func numberOfItems() -> Int

  func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell

  func shouldPaginate() -> Bool
}

class GraphQLCollectionEngineDelegate
  <Query: GraphQLCollectionQuery, Collection: GraphQLCollectionObject, Cell: RenderableCell>: GraphQLCollectionEngine {

  typealias CollectionObject = Collection.Object

  let userId: String

  init(userId: String) {
    self.userId = userId
  }

  var collection: Collection?
  var paginating: Bool = false
  weak var tableView: UITableView?

  func setup() {
    if let tableView = tableView {
      Cell.register(inTableView: tableView)
    }
  }

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
      response in
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

  func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Cell.reuseIdentifier, forIndexPath: indexPath) as! RenderableCell
    cell.render(itemAtIndexPath(indexPath))
    return cell as! UITableViewCell
  }

  private func itemAtIndexPath(indexPath: NSIndexPath) -> CollectionObject {
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
