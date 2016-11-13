import Foundation
import UIKit

protocol GraphQLCollectionEngine {
  weak var tableView: UITableView? { get set }

  func setup()

  func initialFetch()

  func paginate()

  func numberOfItems() -> Int

  func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell

  func objectAtIndexPath(_ indexPath: IndexPath) -> GraphQLObject

  func cellHeight() -> CGFloat

  func shouldPaginate() -> Bool
}

protocol CollectionRendering {
  associatedtype CollectionQuery: GraphQLCollectionQuery
  associatedtype CollectionCell: RenderableCell

  static var batchSize: Int { get }
}

class GraphQLCollectionEngineDelegate<Rendering: CollectionRendering>: GraphQLCollectionEngine {

  typealias CollectionObject = Rendering.CollectionQuery.Object.Object

  let userId: String

  init(userId: String) {
    self.userId = userId
  }

  var collection: Rendering.CollectionQuery.Object?
  var paginating: Bool = false
  weak var tableView: UITableView?

  func setup() {
    if let tableView = tableView {
      Rendering.CollectionCell.register(inTableView: tableView)
    }
  }

  func initialFetch() {
    let queryResolver = GraphQLQueryResolver(query: Rendering.CollectionQuery(id: userId, limit: Rendering.batchSize, next: nil))
    queryResolver.fetch() {
      response in
      switch response {
      case .success(let collection):
        self.updateCollection(collection)
      case .error(let error):
        print(error)
      }
    }
  }

  func paginate() {
    guard let collection = collection else {
      preconditionFailure("trying to paginate without a collection")
    }
    paginating = true
    let query = Rendering.CollectionQuery(id: userId, limit: Rendering.batchSize, next: collection.next())
    let nextPageResolver = GraphQLQueryResolver(query: query)
    nextPageResolver.fetch() {
      response in
      switch response {
      case .success(let collection):
        self.appendObjects(collection)
      case .error(let error):
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

  func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Rendering.CollectionCell.reuseIdentifier, for: indexPath) as! RenderableCell
    cell.render(itemAtIndexPath(indexPath))
    return cell as! UITableViewCell
  }

  func objectAtIndexPath(_ indexPath: IndexPath) -> GraphQLObject {
    return itemAtIndexPath(indexPath)
  }

  fileprivate func itemAtIndexPath(_ indexPath: IndexPath) -> Rendering.CollectionQuery.Object.Object {
    guard let collection = collection else {
      preconditionFailure("trying to access an object (\(indexPath)) without a collection")
    }
    return collection.itemAtIndexPath(indexPath)
  }

  func cellHeight() -> CGFloat {
    return Rendering.CollectionCell.height
  }

  func shouldPaginate() -> Bool {
    return collection != nil && !paginating && collection?.next() != nil
  }

  fileprivate func updateCollection(_ newCollection: Rendering.CollectionQuery.Object) {
    collection = newCollection
    tableView?.reloadData()
  }

  fileprivate func appendObjects(_ newCollection: Rendering.CollectionQuery.Object) {
    guard let _collection = collection else {
      preconditionFailure("Trying to paginate before having any tracks")
    }
    collection = _collection.appendObjects(newCollection)
    tableView?.reloadData()
  }
}
