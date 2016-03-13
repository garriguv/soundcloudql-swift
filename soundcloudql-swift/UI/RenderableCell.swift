import Foundation
import UIKit

protocol RenderableCell {
  func render(object: GraphQLObject)

  static func register(inTableView tableView: UITableView)
  static var reuseIdentifier: String { get }
}

extension RenderableCell where Self: UITableViewCell {
  static func register(inTableView tableView: UITableView) {
    let nib = UINib(nibName: Self.reuseIdentifier, bundle: NSBundle.mainBundle())
    tableView.registerNib(nib, forCellReuseIdentifier: Self.reuseIdentifier)
  }

  static var reuseIdentifier: String {
    return String(self)
  }
}
