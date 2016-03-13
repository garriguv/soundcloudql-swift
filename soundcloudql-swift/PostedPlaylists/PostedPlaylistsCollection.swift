import Foundation

class PostedPlaylistsCollection: CollectionRendering {
  typealias CollectionQuery = PostedPlaylistsQuery
  typealias CollectionObject = PostedPlaylists
  typealias CollectionCell = PlaylistTableViewCell

  static let batchSize = 15
}
