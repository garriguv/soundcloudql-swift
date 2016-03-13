import Foundation

protocol GraphQLQuery {
  typealias Object: GraphQLObject

  var name: String { get }
  var variables: [String: AnyObject] { get }
}

protocol GraphQLObject {
  init?(json: [String: AnyObject])
}

protocol GraphQLCollectionQuery: GraphQLQuery {
  init(userId: String, limit: Int, next: String?)
}

protocol GraphQLCollectionObject: GraphQLObject {
  typealias Object: GraphQLObject

  func numberOfItems() -> Int
  func itemAtIndexPath(indexPath: NSIndexPath) -> Object
  func next() -> String?
  func appendObjects(object: Self) -> Self
}
