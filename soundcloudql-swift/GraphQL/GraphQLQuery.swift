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
  typealias Object: GraphQLCollectionObject

  init(userId: String, limit: Int, next: String?)
}

protocol GraphQLCollectionObject: GraphQLObject {
  func numberOfItems() -> Int
  func itemAtIndexPath(indexPath: NSIndexPath) -> Track
  func next() -> String?
  func appendObjects(object: Self) -> Self
}
