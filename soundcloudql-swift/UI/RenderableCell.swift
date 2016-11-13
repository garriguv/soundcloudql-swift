import Foundation
import UIKit

protocol RenderableCell {
  func render(_ object: GraphQLObject)

  static func register(inTableView tableView: UITableView)
  static var reuseIdentifier: String { get }
  static var height: CGFloat { get }
}

extension RenderableCell where Self: UITableViewCell {
  static func register(inTableView tableView: UITableView) {
    let nib = UINib(nibName: Self.reuseIdentifier, bundle: Bundle.main)
    tableView.register(nib, forCellReuseIdentifier: Self.reuseIdentifier)
  }

  static var reuseIdentifier: String {
    return String(describing: self)
  }
}
