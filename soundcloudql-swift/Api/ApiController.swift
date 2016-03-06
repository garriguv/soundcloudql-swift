import Foundation

enum ApiControllerError: ErrorType {
  case GraphQLQueryNotFound
  case NetworkError(NSError?)
  case JSONSerialization(String?)
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

enum ApiResponse {
  case GraphQL(NSDictionary)
  case Error(ApiControllerError)
}

extension ApiResponse: Equatable {}

func == (lhs: ApiResponse, rhs: ApiResponse) -> Bool {
  switch (lhs, rhs) {
    case (.GraphQL(let lhsObj), .GraphQL(let rhsObj)):
      return lhsObj == rhsObj
    case (.Error(let lhsError), .Error(let rhsError)):
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

  func fetch(withGraphQLQuery graphQLQueryName: String, variables: [String: String], completion: (ApiResponse) -> ()) {
    guard let request = requestFactory.request(withGraphQLQuery: graphQLQueryName, variables: variables) else {
      completion(.Error(.GraphQLQueryNotFound))
      return
    }
    let dataTask = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
      guard
        let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200,
        let jsonData = data else {
        completion(.Error(.NetworkError(error)))
        return;
      }
      do {
        let json = try ApiController.jsonDictionary(jsonData)
        completion(.GraphQL(json))
      } catch let error as NSError? {
        completion(.Error(.JSONSerialization(error?.localizedDescription)))
      } catch let error as ApiControllerError {
        completion(.Error(error))
      } catch {
        completion(.Error(.JSONSerialization(nil)))
      }
    }
    dataTask.resume()
  }

  private static func jsonDictionary(data: NSData) throws -> NSDictionary {
    let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
    if let dictionary = json as? NSDictionary {
      return dictionary
    } else {
      throw ApiControllerError.JSONSerialization("Top level json object is not an NSDictionary: \(json)")
    }
  }
}
