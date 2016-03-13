import Foundation

struct LikedTracksCollection: CollectionRendering {
  typealias CollectionQuery = LikedTracksQuery
  typealias CollectionObject = LikedTracks
  typealias CollectionCell = TrackTableViewCell

  static let batchSize = 50
}
