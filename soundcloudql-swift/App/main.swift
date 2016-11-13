import Foundation

import Foundation
import UIKit

func runningTestBundle() -> Bool {
  let environment = ProcessInfo.processInfo.environment
  if let injectBundle = environment["XCInjectBundle"] {
    return NSString(string: injectBundle).pathExtension == "xctest"
  }
  return false
}

class UnitTestsAppDelegate: UIResponder, UIApplicationDelegate {}

let appDelegateClass: AnyClass? = runningTestBundle() ? UnitTestsAppDelegate.self : AppDelegate.self
let args = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc))
UIApplicationMain(CommandLine.argc, args, nil, NSStringFromClass(appDelegateClass!))
