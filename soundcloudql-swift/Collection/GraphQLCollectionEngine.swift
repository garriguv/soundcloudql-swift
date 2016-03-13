import Foundation
import UIKit

protocol GraphQLCollectionEngine {
  weak var tableView: UITableView? { get set }

  func setup()

  func initialFetch()

  func paginate()

  func numberOfItems() -> Int

  func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell

  func cellHeight() -> CGFloat

  func shouldPaginate() -> Bool
}

protocol CollectionRendering {
  typealias CollectionQuery: GraphQLCollectionQuery
  typealias CollectionCell: RenderableCell

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
    let queryResolver = GraphQLQueryResolver(query: Rendering.CollectionQuery(userId: userId, limit: Rendering.batchSize, next: nil))
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
    let query = Rendering.CollectionQuery(userId: userId, limit: Rendering.batchSize, next: collection.next())
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
    let cell = tableView.dequeueReusableCellWithIdentifier(Rendering.CollectionCell.reuseIdentifier, forIndexPath: indexPath) as! RenderableCell
    cell.render(itemAtIndexPath(indexPath))
    return cell as! UITableViewCell
  }

  func cellHeight() -> CGFloat {
    return Rendering.CollectionCell.height
  }

  private func itemAtIndexPath(indexPath: NSIndexPath) -> Rendering.CollectionQuery.Object.Object {
    guard let collection = collection else {
      preconditionFailure("trying to access a track (\(indexPath)) without a collection")
    }
    return collection.itemAtIndexPath(indexPath)
  }

  func shouldPaginate() -> Bool {
    return collection != nil && !paginating && collection?.next() != nil
  }

  private func updateCollection(newCollection: Rendering.CollectionQuery.Object) {
    collection = newCollection as! Rendering.CollectionQuery.Object
    tableView?.reloadData()
  }

  private func appendObjects(newCollection: Rendering.CollectionQuery.Object) {
    guard let _collection = collection else {
      preconditionFailure("Trying to paginate before having any tracks")
    }
    collection = _collection.appendObjects(newCollection as! Rendering.CollectionQuery.Object)
    tableView?.reloadData()
  }
}
