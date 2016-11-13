import Foundation
import UIKit

protocol CollectionTableViewControllerDelegate: class {
  func viewDidDisappear()
  func didSelectObject(_ object: GraphQLObject)
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

  override func didMove(toParentViewController parent: UIViewController?) {
    if parent == nil {
      collectionDelegate?.viewDidDisappear()
    }
  }
}

// UITableViewDataSource

extension CollectionTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collectionEngine.numberOfItems()
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return collectionEngine.tableView(tableView, cellForRowAtIndexPath: indexPath)
  }
}

// UITableViewDelegate

extension CollectionTableViewController {
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return collectionEngine.cellHeight()
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    collectionDelegate?.didSelectObject(collectionEngine.objectAtIndexPath(indexPath))
  }
}

// UIScrollViewDelegate

extension CollectionTableViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if paginationShouldBeTriggered(scrollView) {
      collectionEngine.paginate()
    }
  }

  fileprivate func paginationShouldBeTriggered(_ scrollView: UIScrollView) -> Bool {
    if collectionEngine.shouldPaginate() {
      return (scrollView.contentSize.height - scrollView.frame.size.height) - scrollView.contentOffset.y < tableView.frame.size.height * 2
    } else {
      return false
    }
  }
}
