import Foundation

class GraphQLQueryResolver<Query: GraphQLQuery> {
  let query: Query
  let apiController: ApiController

  init(query: Query, apiController: ApiController = ApiController.sharedInstance) {
    self.query = query
    self.apiController = apiController
  }

  func fetch(closure: (QueryResponse<Query.Object>) -> ()) {
    apiController.fetch(withGraphQLQuery: query.name, variables: query.variables) { apiResponse in
      switch (apiResponse) {
        case .GraphQL(let dictionary):
          if let object = Query.Object(json: dictionary) {
            closure(.Success(object))
          } else {
            closure(.Error(.SerializationError))
          }
        case .Error(let error):
          closure(.Error(.ApiError(error)))
      }
    }
  }
}

enum QueryResponse<Object> {
  case Success(Object)
  case Error(QueryError)
}

enum QueryError {
  case ApiError(ApiControllerError)
  case SerializationError
}

extension QueryError: Equatable {}

func == (lhs: QueryError, rhs: QueryError) -> Bool {
  switch (lhs, rhs) {
  case (.ApiError(let lhsError), .ApiError(let rhsError)):
    return lhsError == rhsError
  case (.SerializationError, .SerializationError):
    return true
  default:
    return false
  }
}
