import Foundation

protocol GraphQLQuery {
  typealias Object: GraphQLObject

  var name: String { get }
  var variables: [String: String] { get }
}

protocol GraphQLObject {
  init?(json: [String: AnyObject])
}
