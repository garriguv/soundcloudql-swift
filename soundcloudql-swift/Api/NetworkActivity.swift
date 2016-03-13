import Foundation
import UIKit

class NetworkActivity {
  static var counter: Int = 0

  static func increase() {
    counter++
    updateIndicatorVisibility()
  }

  static func decrease() {
    counter--
    updateIndicatorVisibility()
  }

  private static func updateIndicatorVisibility() {
    precondition(counter >= 0, "counter should never be < 0")
    UIApplication.sharedApplication().networkActivityIndicatorVisible = counter > 0
  }
}
