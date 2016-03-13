import Foundation

class PostedTracksCollection: CollectionRendering {
  typealias CollectionQuery = PostedTracksQuery
  typealias CollectionCell = TrackTableViewCell

  static let batchSize = 50
}
