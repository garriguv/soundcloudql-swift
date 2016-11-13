import Foundation

struct PlaylistTracksQuery: GraphQLQuery {
  typealias Object = PlaylistTracks

  let name = "playlist_tracks"
  let variables: [String: Any]

  init(id: String, limit: Int, next: String?) {
    var variables: [String: Any] = [ "id": id, "limit" : limit ]
    if let next = next {
      variables["next"] = next
    }
    self.variables = variables
  }
}

struct PlaylistTracks {
  let playlist: PlaylistTracksPlaylist
}

extension PlaylistTracks: GraphQLObject {
  init?(json: [String:Any]) {
    guard let playlistJson = json["playlist"] as? [String: Any],
    let playlist = PlaylistTracksPlaylist(json: playlistJson) else {
      return nil
    }
    self.playlist = playlist
  }
}

struct PlaylistTracksPlaylist {
  let tracksCollection: PlaylistTracksCollection
}

extension PlaylistTracksPlaylist: GraphQLObject {
  init?(json: [String:Any]) {
    guard let tracksCollectionJson = json["tracksCollection"] as? [String: Any],
    let tracksCollection = PlaylistTracksCollection(json: tracksCollectionJson) else {
      return nil
    }
    self.tracksCollection = tracksCollection
  }
}
