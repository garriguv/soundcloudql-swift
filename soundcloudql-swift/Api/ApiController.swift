import Foundation

enum ApiControllerError: ErrorType {
  case GraphQLQueryNotFound
  case NetworkError(NSError?)
  case JSONSerialization(NSError?)
}

extension ApiControllerError: Equatable {}

func == (lhs: ApiControllerError, rhs: ApiControllerError) -> Bool {
  switch (lhs, rhs) {
    case (.GraphQLQueryNotFound, .GraphQLQueryNotFound):
      return true
    case (.NetworkError(let lhsError), .NetworkError(let rhsError)):
      return lhsError == rhsError
    case (.JSONSerialization(let lhsError), .JSONSerialization(let rhsError)):
      return lhsError == rhsError
    default:
      return false
  }
}

class ApiController {
  static let sharedInstance = ApiController()

  private let session: NSURLSession
  private let requestFactory: RequestFactory

  init(session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()),
       requestFactory: RequestFactory = RequestFactory()) {
    self.session = session
    self.requestFactory = requestFactory
  }

  func fetch(withGraphQLQuery graphQLQueryName: String, variables: [String: String], completion: ([String: AnyObject]?, ApiControllerError?) -> ()) {
    guard let request = requestFactory.request(withGraphQLQuery: graphQLQueryName, variables: variables) else {
      completion(nil, ApiControllerError.GraphQLQueryNotFound)
      return
    }
    let dataTask = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
      guard
        let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200,
        let jsonData = data else {
        completion(nil, ApiControllerError.NetworkError(error))
        return;
      }
      do {
        let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
        completion(json as? [String: AnyObject], nil)
      } catch let error as NSError? {
        completion(nil, ApiControllerError.JSONSerialization(error))
      } catch {
        completion(nil, ApiControllerError.JSONSerialization(nil))
      }
    }
    dataTask.resume()
  }
}
