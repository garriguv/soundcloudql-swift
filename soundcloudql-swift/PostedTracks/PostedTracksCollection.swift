import Foundation

class PostedTracksCollection: CollectionRendering {
  typealias CollectionQuery = PostedTracksQuery
  typealias CollectionObject = PostedTracks
  typealias CollectionCell = TrackTableViewCell

  static let batchSize = 50
}
