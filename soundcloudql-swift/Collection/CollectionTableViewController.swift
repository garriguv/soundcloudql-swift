import Foundation
import UIKit

protocol CollectionTableViewControllerDelegate {
  func viewDidDisappear()
}

class CollectionTableViewController: UITableViewController {
  var collectionEngine: GraphQLCollectionEngine!

  var collectionDelegate: CollectionTableViewControllerDelegate?

  private var paginating: Bool = false
}

// View lifecycle

extension CollectionTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    collectionEngine.tableView = tableView
    collectionEngine.setup()
    collectionEngine.initialFetch()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    collectionDelegate?.viewDidDisappear()
  }
}

// UITableViewDataSource

extension CollectionTableViewController {
  override func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collectionEngine.numberOfItems()
  }

  override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return collectionEngine.tableView(tableView, cellForRowAtIndexPath: indexPath)
  }
}

// UITableViewDelegate

extension CollectionTableViewController {
  override func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return collectionEngine.cellHeight()
  }

  override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

// UIScrollViewDelegate

extension CollectionTableViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
