import Foundation

class Environment {
  static let sharedInstance = Environment()

  fileprivate let environment: [String: AnyObject]

  init(_ bundle: Bundle = Bundle.main) {
    self.environment = Environment.loadEnvironment(bundle)
  }

  var graphQLURL: URL {
    guard let urlString = self.environment["graphql_url"] as? String, let url = URL(string: urlString) else {
      preconditionFailure("Could not load graphql_url in environment \(self.environment)")
    }
    return url
  }

  fileprivate static func loadEnvironment(_ bundle: Bundle) -> [String: AnyObject] {
    guard let environmentURL = bundle.url(forResource: "Environment", withExtension: "plist") else {
      preconditionFailure("could not find environment in bundle \(bundle)")
    }
    guard let dictionary = NSDictionary(contentsOf: environmentURL) as? [String: AnyObject] else {
      preconditionFailure("could not load environment at \(environmentURL)")
    }
    return dictionary
  }
}
