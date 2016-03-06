import Quick
import Nimble
@testable import soundcloudql_swift

class TestNSURLSessionDataTask: NSURLSessionDataTask {
  let __completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void
  let __data: NSData?
  let __response: NSURLResponse?
  let __error: NSError?

  init(completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void,
       data: NSData?,
       response: NSURLResponse?,
       error: NSError?) {
    self.__completionHandler = completionHandler
    self.__data = data
    self.__response = response
    self.__error = error
  }

  override func resume() {
    __completionHandler(__data, __response, __error)
  }
}

class TestNSURLSession: NSURLSession {
  var __data: NSData?
  var __response: NSURLResponse?
  var __error: NSError?

  override func dataTaskWithRequest(_ request: NSURLRequest, completionHandler completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
    let testDataTask = TestNSURLSessionDataTask(completionHandler: completionHandler,
      data: __data, response: __response, error: __error)
    return testDataTask
  }
}

class TestRequestFactory: RequestFactory {
  var __request: NSURLRequest?

  override func request(withGraphQLQuery queryName: String, variables: [String:String]) -> NSURLRequest? {
    return __request
  }
}

class ApiControllerSpec: QuickSpec {
  override func spec() {
    var subject: ApiController!

    var session: TestNSURLSession!
    var requestFactory: TestRequestFactory!

    let url = NSURL(string: "http://localhost:5000/graphql")!

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
              expect(response).to(equal(ApiResponse.Error(.GraphQLQueryNotFound)))
              done()
            }
          }
        }
      }

      context("when the request factroy returns a request") {
        beforeEach {
          requestFactory.__request = NSURLRequest(URL: url)
        }

        context("when the api errors") {
          var networkResponse: NSHTTPURLResponse!
          var networkError: NSError!

          beforeEach {
            networkResponse = NSHTTPURLResponse(URL: url, statusCode: 500, HTTPVersion: nil, headerFields: nil)
            networkError = NSError(domain: "network", code: 1337, userInfo: nil)
            session.__error = networkError
            session.__response = networkResponse
          }

          it("returns NetworkError") {
            waitUntil { done in
              subject.fetch(withGraphQLQuery: "query", variables: [String: String]()) {
                (response: ApiResponse) in
                expect(response).to(equal(ApiResponse.Error(.NetworkError(networkError))))
                done()
              }
            }
          }
        }

        context("when the JSON serialization errors") {
          var networkResponse: NSHTTPURLResponse!
          var networkData: NSData!

          beforeEach {
            networkResponse = NSHTTPURLResponse(URL: url, statusCode: 200, HTTPVersion: nil, headerFields: nil)
            networkData = NSData()
            session.__response = networkResponse
            session.__data = networkData
          }

          it("returns JSONSerialization") {
            waitUntil { done in
              subject.fetch(withGraphQLQuery: "query", variables: [String: String]()) {
                (response: ApiResponse) in
                expect(response).to(equal(ApiResponse.Error(.JSONSerialization(nil))))
                done()
              }
            }
          }
        }

        context("when the api and JSON serialization succeeds") {
          var networkResponse: NSHTTPURLResponse!
          var networkData: NSData!
          var expectedDictionary: NSDictionary!

          beforeEach {
            expectedDictionary = [ "data": [ "hello" : "world" ] ] as! NSDictionary
            networkResponse = NSHTTPURLResponse(URL: url, statusCode: 200, HTTPVersion: nil, headerFields: nil)
            networkData = try! NSJSONSerialization.dataWithJSONObject(expectedDictionary, options: [])
            session.__response = networkResponse
            session.__data = networkData
          }

          it("returns a dictionary") {
            waitUntil { done in
              subject.fetch(withGraphQLQuery: "query", variables: [String: String]()) {
                (response: ApiResponse) in
                expect(response).to(equal(ApiResponse.GraphQL(expectedDictionary)))
                done()
              }
            }
          }
        }
      }
    }
  }
}
