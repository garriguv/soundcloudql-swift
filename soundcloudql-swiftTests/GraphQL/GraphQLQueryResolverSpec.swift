import Quick
import Nimble
@testable import soundcloudql_swift

struct TestGraphQLQuery: GraphQLQuery {
  typealias Object = TestObject

  var name: String {
    return "test_query"
  }
  var variables: [String:Any] {
    return [ "id" : "2" ]
  }
}

struct TestObject {
  let id: String
}

extension TestObject: Equatable {}

func == (lhs: TestObject, rhs: TestObject) -> Bool {
  return lhs.id == rhs.id
}

extension TestObject: GraphQLObject {
  init?(json: [String:Any]) {
    guard let id = json["id"] as? String else {
      return nil;
    }
    self.id = id
  }
}

class TestApiController: ApiController {
  var __response: ApiResponse!

  init() { }

  override func fetch(withGraphQLQuery graphQLQueryName: String, variables: [String:Any], completion: @escaping (ApiResponse) -> ()) {
    completion(__response)
  }
}

class GraphQLQueryResolverSpec: QuickSpec {
  override func spec() {
    var subject: GraphQLQueryResolver<TestGraphQLQuery>!

    var query: TestGraphQLQuery!
    var apiController: TestApiController!

    beforeEach {
      query = TestGraphQLQuery()
      apiController = TestApiController()

      subject = GraphQLQueryResolver(query: query, apiController: apiController)
    }

    describe("fetch()") {
      context("when the api returns a dictionary") {
        context("when the dictionary contains valid data") {
          beforeEach {
            apiController.__response = ApiResponse.graphQL([ "data": [ "id": "2" ] ])
          }

          it("completes with Success(object)") {
            waitUntil { done in
              subject.fetch { (response: QueryResponse<TestObject>) in
                switch response {
                case .success(let object):
                  expect(object).to(equal(TestObject(id: "2")))
                default:
                  assertionFailure("boom \(response)")
                }
              }
              done()
            }
          }
        }

        context("when the dictionary contains invalid data") {
          beforeEach {
            apiController.__response = ApiResponse.graphQL([ "data": [ "invalid": "data" ] ])
          }

          it("completes with Error(.SerializationError)") {
            waitUntil { done in
              subject.fetch { (response: QueryResponse<TestObject>) in
                switch response {
                case .error(let error):
                  expect(error).to(equal(QueryError.serializationError([ "data": [ "invalid": "data" ] ])))
                default:
                  assertionFailure("boom \(response)")
                }
              }
              done()
            }
          }
        }
      }

      context("when the api errors") {
        beforeEach {
          apiController.__response = ApiResponse.error(.graphQLQueryNotFound)
        }

        it("completes with Error(.ApiError(error))") {
          waitUntil { done in
            subject.fetch { (response: QueryResponse<TestObject>) in
              switch response {
              case .error(let error):
                expect(error).to(equal(QueryError.apiError(.graphQLQueryNotFound)))
              default:
                assertionFailure("boom \(response)")
              }
            }
            done()
          }
        }
      }
    }
  }
}
