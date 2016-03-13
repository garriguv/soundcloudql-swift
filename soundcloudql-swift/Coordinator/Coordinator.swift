import Foundation

protocol Coordinator: class {
  var delegate: CoordinatorDelegate? { get set }
  var childCoordinators: [Coordinator] { get set }

  func start()
}

protocol CoordinatorDelegate: class {
  func didFinishCoordinating(coordinator: Coordinator)
}

extension Coordinator {
  func didFinishCoordinating(coordinator: Coordinator) {
    let index = childCoordinators.indexOf { $0 === coordinator }!
    childCoordinators.removeAtIndex(index)
  }
}
