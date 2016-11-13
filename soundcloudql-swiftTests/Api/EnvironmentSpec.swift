import Quick
import Nimble
@testable import soundcloudql_swift

class EnvironmentSpec: QuickSpec {
  override func spec() {
    var subject: Environment!

    beforeEach {
      subject = Environment(Bundle(for: type(of: self)))
    }

    describe("graphQLURL") {
      it("returns the graphQLURL") {
        expect(subject.graphQLURL).to(equal(URL(string: "http://localhost:5000/graphql")!))
      }
    }
  }
}
