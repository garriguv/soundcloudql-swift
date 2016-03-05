import Foundation

class Environment {
  static let sharedInstance = Environment()

  private let environment: [String: AnyObject]

  init(_ bundle: NSBundle = NSBundle.mainBundle()) {
    self.environment = Environment.loadEnvironment(bundle)
  }

  lazy var graphQLURL: NSURL = {
    guard let urlString = self.environment["graphql_url"] as? String, let url = NSURL(string: urlString) else {
      fatalError("Could not load graphql_url in environment \(self.environment)")
    }
    return url
  }()

  private static func loadEnvironment(bundle: NSBundle) -> [String: AnyObject] {
    guard let environmentURL = bundle.URLForResource("Environment", withExtension: "plist") else {
      fatalError("could not find environment in bundle \(bundle)")
    }
    guard let dictionary = NSDictionary(contentsOfURL: environmentURL) as? [String: AnyObject] else {
      fatalError("could not load environment at \(environmentURL)")
    }
    return dictionary
  }
}
