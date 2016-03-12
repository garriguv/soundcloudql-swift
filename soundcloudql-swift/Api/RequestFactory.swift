import Foundation

class RequestFactory {

  private let bundle: NSBundle
  private let environment: Environment

  init(bundle: NSBundle = NSBundle.mainBundle(), environment: Environment = Environment.sharedInstance) {
    self.bundle = bundle
    self.environment = environment
  }

  func request(withGraphQLQuery queryName: String, variables: [String: AnyObject]) -> NSURLRequest? {
    guard
      let query = graphQLQuery(queryName),
      let body = body(withQuery: query, variables: variables) else {
      return nil
    }
    let request = NSMutableURLRequest(URL: environment.graphQLURL)

    request.HTTPBody = body
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    return request
  }

  private func graphQLQuery(queryName: String) -> String? {
    guard let queryURL = bundle.URLForResource(queryName, withExtension: "graphql") else {
      return nil
    }
    return try? String(contentsOfURL: queryURL, encoding: NSUTF8StringEncoding)
  }

  private func body(withQuery query: String, variables: [String: AnyObject]) -> NSData? {
    let body = [
      "query" : query,
      "variables" : variables
    ]
    return try? NSJSONSerialization.dataWithJSONObject(body, options: [])
  }

}
