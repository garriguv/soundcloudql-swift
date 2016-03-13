import Foundation

struct FollowingsCollection: CollectionRendering {
  typealias CollectionQuery = FollowingsQuery
  typealias CollectionCell = UserTableViewCell

  static let batchSize = 50
}
