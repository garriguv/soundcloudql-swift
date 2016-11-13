import Quick
import Nimble
@testable import soundcloudql_swift

class TestEnvironment: Environment {
  override var graphQLURL: URL { return URL(string: "http://localhost:5000/graphql")! }
}

class RequestFactorySpec: QuickSpec {
  override func spec() {
    var subject: RequestFactory!

    var bundle: Bundle!
    var environment: TestEnvironment!

    beforeEach {
      bundle = Bundle(for: type(of: self))
      environment = TestEnvironment()

    subject = RequestFactory(bundle: bundle, environment: environment)
    }

    describe("request(queryName:variables:)") {
      context("when the query exists") {
        var request: (() -> URLRequest)!

        beforeEach {
          request = {
            return subject.request(withGraphQLQuery:"query", variables: [ "id": "2" ])!
          }
        }

        it("returns a request with the right URL") {
          expect(request().url).to(equal(URL(string: "http://localhost:5000/graphql")))
        }

        it("returns a request with the right content type") {
          expect(request().allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
        }

        it("returns a request with the right method") {
          expect(request().httpMethod).to(equal("POST"))
        }

        it("returns a request with the right body") {
          let expectedBody: NSDictionary = [
            "query" : "user(id: $id) {\n  username\n}\n",
            "variables" : [
              "id" : "2"
            ]
          ]
          let requestBody = try! JSONSerialization.jsonObject(with: request().httpBody!, options: []) as! NSDictionary
          expect(requestBody).to(equal(expectedBody))
        }
      }

      context("when the query does not exist") {
        it("does not return any request") {
          expect(subject.request(withGraphQLQuery:"nope", variables: [String: String]())).to(beNil())
        }
      }
    }
  }
}
