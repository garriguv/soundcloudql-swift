import Foundation

import Foundation
import UIKit

func runningTestBundle() -> Bool {
  let environment = NSProcessInfo.processInfo().environment
  if let injectBundle = environment["XCInjectBundle"] {
    return NSString(string: injectBundle).pathExtension == "xctest"
  }
  return false
}

class UnitTestsAppDelegate: UIResponder, UIApplicationDelegate {}

if runningTestBundle() {
  UIApplicationMain(Process.argc, Process.unsafeArgv, NSStringFromClass(UIApplication), NSStringFromClass(UnitTestsAppDelegate))
} else {
  UIApplicationMain(Process.argc, Process.unsafeArgv, NSStringFromClass(UIApplication), NSStringFromClass(AppDelegate))
}
