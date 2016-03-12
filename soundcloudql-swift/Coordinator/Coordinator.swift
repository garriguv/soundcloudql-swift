import Foundation

protocol Coordinator {
  var delegate: CoordinatorDelegate? { get set }

  func start()
}

protocol CoordinatorDelegate: class {
  func didFinishCoordinating<T: Coordinator>(coordinator: T)
}
