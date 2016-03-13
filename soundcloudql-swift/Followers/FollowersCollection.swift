import Foundation

struct FollowersCollection: CollectionRendering {
  typealias CollectionQuery = FollowersQuery
  typealias CollectionCell = UserTableViewCell

  static let batchSize = 50
}
