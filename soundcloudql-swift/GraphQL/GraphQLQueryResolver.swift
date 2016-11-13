import Foundation

class GraphQLQueryResolver<Query: GraphQLQuery> {
  let query: Query
  let apiController: ApiController

  init(query: Query, apiController: ApiController = ApiController.sharedInstance) {
    self.query = query
    self.apiController = apiController
  }

  func fetch(_ closure: @escaping (QueryResponse<Query.Object>) -> ()) {
    print("resolving \(query)")
    apiController.fetch(withGraphQLQuery: query.name, variables: query.variables) { apiResponse in
      switch (apiResponse) {
        case .graphQL(let dictionary):
          if let json = dictionary["data"] as? [String: Any], let object = Query.Object(json: json) {
            DispatchQueue.main.async {
              closure(.success(object))
            }
          } else {
            DispatchQueue.main.async {
              closure(.error(.serializationError(dictionary)))
            }
          }
        case .error(let error):
          DispatchQueue.main.async {
            closure(.error(.apiError(error)))
          }
      }
    }
  }
}

enum QueryResponse<Object> {
  case success(Object)
  case error(QueryError)
}

enum QueryError {
  case apiError(ApiControllerError)
  case serializationError([String: Any])
}

extension QueryError: Equatable {}

func == (lhs: QueryError, rhs: QueryError) -> Bool {
  switch (lhs, rhs) {
  case (.apiError(let lhsError), .apiError(let rhsError)):
    return lhsError == rhsError
  case (.serializationError(let lhsDictionary), .serializationError(let rhsDictionary)):
    return NSDictionary(dictionary: lhsDictionary).isEqual(to: rhsDictionary)
  default:
    return false
  }
}
