import Foundation
import UIKit

protocol CollectionTableViewControllerDelegate: class {
  func viewDidDisappear()
}

class CollectionTableViewController: UITableViewController {
  var collectionEngine: GraphQLCollectionEngine!
  weak var collectionDelegate: CollectionTableViewControllerDelegate?
}

// View lifecycle

extension CollectionTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    collectionEngine.tableView = tableView
    collectionEngine.setup()
    collectionEngine.initialFetch()
  }

  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)

    collectionDelegate?.viewDidDisappear()
  }
}

// UITableViewDataSource

extension CollectionTableViewController {
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collectionEngine.numberOfItems()
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return collectionEngine.tableView(tableView, cellForRowAtIndexPath: indexPath)
  }
}

// UITableViewDelegate

extension CollectionTableViewController {
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return collectionEngine.cellHeight()
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

// UIScrollViewDelegate

extension CollectionTableViewController {
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    if paginationShouldBeTriggered(scrollView) {
      collectionEngine.paginate()
    }
  }

  private func paginationShouldBeTriggered(scrollView: UIScrollView) -> Bool {
    if collectionEngine.shouldPaginate() {
      return (scrollView.contentSize.height - scrollView.frame.size.height) - scrollView.contentOffset.y < tableView.frame.size.height * 2
    } else {
      return false
    }
  }
}
