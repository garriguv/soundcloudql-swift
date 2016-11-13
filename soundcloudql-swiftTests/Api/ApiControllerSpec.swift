import Quick
import Nimble
@testable import soundcloudql_swift

class TestNSURLSessionDataTask: URLSessionDataTask {
  let __completionHandler: (Data?, URLResponse?, Error?) -> Void
  let __data: Data?
  let __response: URLResponse?
  let __error: Error?

  init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void,
       data: Data?,
       response: URLResponse?,
       error: Error?) {
    self.__completionHandler = completionHandler
    self.__data = data
    self.__response = response
    self.__error = error
  }

  override func resume() {
    __completionHandler(__data, __response, __error)
  }
}

class TestNSURLSession: URLSession {
  var __data: Data?
  var __response: URLResponse?
  var __error: Error?

  override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    let testDataTask = TestNSURLSessionDataTask(completionHandler: completionHandler,
                                                data: __data, response: __response, error: __error)
    return testDataTask
  }
}

class TestRequestFactory: RequestFactory {
  var __request: URLRequest?

  override func request(withGraphQLQuery queryName: String, variables: [String: Any]) -> URLRequest? {
    return __request
  }
}

class ApiControllerSpec: QuickSpec {
  override func spec() {
    var subject: ApiController!

    var session: TestNSURLSession!
    var requestFactory: TestRequestFactory!

    let url = URL(string: "http://localhost:5000/graphql")!

    beforeEach {
      session = TestNSURLSession()
      requestFactory = TestRequestFactory()

      subject = ApiController(session: session, requestFactory: requestFactory)
    }

    describe("fetch(withGraphQLQuery:variables:)") {
      context("when the request factory does not return a request") {
        beforeEach {
          requestFactory.__request = nil
        }

        it("returns GraphQLQueryNotFound") {
          waitUntil { done in
            subject.fetch(withGraphQLQuery: "query", variables: [String: String]()) {
              (response: ApiResponse) in
              expect(response).to(equal(ApiResponse.error(.graphQLQueryNotFound)))
              done()
            }
          }
        }
      }

      context("when the request factroy returns a request") {
        beforeEach {
          requestFactory.__request = URLRequest(url: url)
        }

        context("when the api errors") {
          var networkResponse: HTTPURLResponse!
          var networkError: Error!

          beforeEach {
            networkResponse = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
            networkError = NSError(domain: "network", code: 1337, userInfo: nil)
            session.__error = networkError
            session.__response = networkResponse
          }

          it("returns NetworkError") {
            waitUntil { done in
              subject.fetch(withGraphQLQuery: "query", variables: [String: String]()) {
                (response: ApiResponse) in
                expect(response).to(equal(ApiResponse.error(.networkError(networkError))))
                done()
              }
            }
          }
        }

        context("when the JSON serialization errors") {
          var networkResponse: HTTPURLResponse!
          var networkData: Data!

          beforeEach {
            networkResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            networkData = Data()
            session.__response = networkResponse
            session.__data = networkData
          }

          it("returns JSONSerialization") {
            waitUntil { done in
              subject.fetch(withGraphQLQuery: "query", variables: [String: String]()) {
                (response: ApiResponse) in
                expect(response).to(equal(ApiResponse.error(.jsonSerialization(nil))))
                done()
              }
            }
          }
        }

        context("when the api and JSON serialization succeeds") {
          var networkResponse: HTTPURLResponse!
          var networkData: Data!
          var expectedDictionary: [String: Any]!

          beforeEach {
            expectedDictionary = ["data": ["hello": "world"]]
            networkResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            networkData = try! JSONSerialization.data(withJSONObject: expectedDictionary, options: [])
            session.__response = networkResponse
            session.__data = networkData
          }

          it("returns a dictionary") {
            waitUntil { done in
              subject.fetch(withGraphQLQuery: "query", variables: [String: String]()) {
                (response: ApiResponse) in
                expect(response).to(equal(ApiResponse.graphQL(expectedDictionary)))
                done()
              }
            }
          }
        }
      }
    }
  }
}
