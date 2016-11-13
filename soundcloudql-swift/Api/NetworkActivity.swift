import Foundation
import UIKit

class NetworkActivity {
  static var counter: Int = 0

  static func increase() {
    counter += 1
    updateIndicatorVisibility()
  }

  static func decrease() {
    counter -= 1
    updateIndicatorVisibility()
  }

  fileprivate static func updateIndicatorVisibility() {
    precondition(counter >= 0, "counter should never be < 0")
    UIApplication.shared.isNetworkActivityIndicatorVisible = counter > 0
  }
}
