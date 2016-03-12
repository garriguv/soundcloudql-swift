import Quick
import Nimble
@testable import soundcloudql_swift

class TestNavigationController: UINavigationController {
  var __pushedViewController: UIViewController?
  var __pushedViewControllerAnimated: Bool?

  override func pushViewController(viewController: UIViewController, animated: Bool) {
    __pushedViewController = viewController
    __pushedViewControllerAnimated = animated
  }
}

class ProfileCoordinatorSpec: QuickSpec {
  override func spec() {
    var subject: ProfileCoordinator!

    var navigationController: TestNavigationController!

    beforeEach {
      navigationController = TestNavigationController()

      subject = ProfileCoordinator(navigationController, userId: "2")
    }

    describe("start()") {
      it("pushes an instance of ProfileCollectionViewController") {
        subject.start()

        expect(navigationController.__pushedViewController).to(beAnInstanceOf(ProfileTableViewController))
      }

      it("pushes a view controller without animating") {
        subject.start()

        expect(navigationController.__pushedViewControllerAnimated).to(beFalse())
      }

      it("sets the pushed view controller title") {
        subject.start()

        expect(navigationController.__pushedViewController?.title).to(equal("Profile"))
      }
    }
  }
}
