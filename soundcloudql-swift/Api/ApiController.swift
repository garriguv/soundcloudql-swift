import Foundation

enum ApiControllerError: Error {
  case graphQLQueryNotFound
  case networkError(Error?)
  case jsonSerialization(String?)
}

extension ApiControllerError: Equatable {}

func == (lhs: ApiControllerError, rhs: ApiControllerError) -> Bool {
  switch (lhs, rhs) {
    case (.graphQLQueryNotFound, .graphQLQueryNotFound):
      return true
    case (.networkError(_), .networkError(_)):
      return true
    case (.jsonSerialization(_), .jsonSerialization(_)):
      return true
    default:
      return false
  }
}

enum ApiResponse {
  case graphQL([String: Any])
  case error(ApiControllerError)
}

extension ApiResponse: Equatable {}

func == (lhs: ApiResponse, rhs: ApiResponse) -> Bool {
  switch (lhs, rhs) {
    case (.graphQL(let lhsObj), .graphQL(let rhsObj)):
      return NSDictionary(dictionary: lhsObj).isEqual(to: rhsObj)
    case (.error(let lhsError), .error(let rhsError)):
      return lhsError == rhsError
    default:
      return false
  }
}

class ApiController {
  static let sharedInstance = ApiController()

  fileprivate let session: URLSession
  fileprivate let requestFactory: RequestFactory

  init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default),
       requestFactory: RequestFactory = RequestFactory()) {
    self.session = session
    self.requestFactory = requestFactory
  }

  func fetch(withGraphQLQuery graphQLQueryName: String, variables: [String: Any], completion: @escaping (ApiResponse) -> ()) {
    guard let request = requestFactory.request(withGraphQLQuery: graphQLQueryName, variables: variables) else {
      completion(.error(.graphQLQueryNotFound))
      return
    }
    NetworkActivity.increase()
    let dataTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
      NetworkActivity.decrease()
      guard
        let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
        let jsonData = data else {
        completion(.error(.networkError(error)))
        return;
      }
      do {
        let json = try ApiController.jsonDictionary(jsonData)
        completion(.graphQL(json))
      } catch let error as NSError? {
        completion(.error(.jsonSerialization(error?.localizedDescription)))
      } catch let error as ApiControllerError {
        completion(.error(error))
      } catch {
        completion(.error(.jsonSerialization(nil)))
      }
    }) 
    dataTask.resume()
  }

  fileprivate static func jsonDictionary(_ data: Data) throws -> [String: AnyObject] {
    let json = try JSONSerialization.jsonObject(with: data, options: [])
    if let dictionary = json as? [String: AnyObject] {
      return dictionary
    } else {
      throw ApiControllerError.jsonSerialization("Top level json object is not an NSDictionary: \(json)")
    }
  }
}
