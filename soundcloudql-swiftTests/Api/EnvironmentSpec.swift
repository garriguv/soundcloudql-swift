import Quick
import Nimble
@testable import soundcloudql_swift

class EnvironmentSpec: QuickSpec {
  override func spec() {
    var subject: Environment!

    beforeEach {
      subject = Environment(NSBundle(forClass: self.dynamicType))
    }

    describe("graphQLURL") {
      it("returns the graphQLURL") {
        expect(subject.graphQLURL).to(equal(NSURL(string: "http://localhost:5000/graphql")!))
      }
    }
  }
}
