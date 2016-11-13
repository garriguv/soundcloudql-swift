import Foundation

class RequestFactory {

  fileprivate let bundle: Bundle
  fileprivate let environment: Environment

  init(bundle: Bundle = Bundle.main, environment: Environment = Environment.sharedInstance) {
    self.bundle = bundle
    self.environment = environment
  }

  func request(withGraphQLQuery queryName: String, variables: [String: Any]) -> URLRequest? {
    guard
      let query = graphQLQuery(queryName),
      let body = body(withQuery: query, variables: variables) else {
      return nil
    }
    let request = NSMutableURLRequest(url: environment.graphQLURL as URL)

    request.httpBody = body
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    return request as URLRequest
  }

  fileprivate func graphQLQuery(_ queryName: String) -> String? {
    guard let queryURL = bundle.url(forResource: queryName, withExtension: "graphql") else {
      return nil
    }
    return try? String(contentsOf: queryURL, encoding: String.Encoding.utf8)
  }

  fileprivate func body(withQuery query: String, variables: [String: Any]) -> Data? {
    let body = [
      "query" : query,
      "variables" : variables
    ] as [String : Any]
    return try? JSONSerialization.data(withJSONObject: body, options: [])
  }

}
