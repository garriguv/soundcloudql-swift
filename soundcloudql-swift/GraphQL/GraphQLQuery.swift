import Foundation

protocol GraphQLQuery {
  associatedtype Object: GraphQLObject

  var name: String { get }
  var variables: [String: Any] { get }
}

protocol GraphQLObject {
  init?(json: [String: Any])
}

protocol GraphQLCollectionQuery: GraphQLQuery {
  associatedtype Object: GraphQLCollectionObject

  init(id: String, limit: Int, next: String?)
}

protocol GraphQLCollectionObject: GraphQLObject {
  associatedtype Object: GraphQLObject

  func numberOfItems() -> Int
  func itemAtIndexPath(_ indexPath: IndexPath) -> Object
  func next() -> String?
  func appendObjects(_ object: Self) -> Self
}
