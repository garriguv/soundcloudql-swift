import Quick
import Nimble
@testable import soundcloudql_swift

class TestTabBarController: UITabBarController {
  var __didCallSetViewControllers: Bool = false
  var __viewControllers: [UIViewController]? = []

  override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
    __didCallSetViewControllers = true
    __viewControllers = viewControllers!
  }
}

class AppCoordinatorSpec: QuickSpec {
  override func spec() {
    var subject: AppCoordinator!

    var tabBarViewController: TestTabBarController!

    beforeEach {
      tabBarViewController = TestTabBarController()

      subject = AppCoordinator(tabBarViewController)
    }

    describe("start") {
      it("sets the view controllers on tabBarViewController") {
        subject.start()

        expect(tabBarViewController.__didCallSetViewControllers).to(beTrue())
      }

      it("sets 1 view controller on tabBarViewController") {
        subject.start()

        expect(tabBarViewController.__viewControllers).to(haveCount(1))
      }
    }
  }
}
