import Foundation

struct LikedTracksCollection: CollectionRendering {
  typealias CollectionQuery = LikedTracksQuery
  typealias CollectionCell = TrackTableViewCell

  static let batchSize = 50
}
