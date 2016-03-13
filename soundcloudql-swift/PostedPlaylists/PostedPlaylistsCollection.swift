import Foundation

class PostedPlaylistsCollection: CollectionRendering {
  typealias CollectionQuery = PostedPlaylistsQuery
  typealias CollectionCell = PlaylistTableViewCell

  static let batchSize = 15
}
