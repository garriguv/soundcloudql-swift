import Foundation

struct PlaylistQuery: GraphQLQuery {
  typealias Object = Playlist

  let name = "playlist"
  let variables: [String: Any]

  init(playlistId: String) {
    self.variables = ["id": playlistId]
  }
}

struct Playlist {
  let id: String
  let title: String
  let description: String?
  let artworkUrl: String?
  let tracksCount: Int
  let userConnection: PlaylistUser
  let tracksCollection: PlaylistTracksCollection
}

extension Playlist: GraphQLObject {
  init?(json: [String: Any]) {
    guard let playlistJson = json["playlist"] as? [String: Any],
      let id = playlistJson["id"] as? String,
      let title = playlistJson["title"] as? String,
      let tracksCount = playlistJson["tracksCount"] as? Int,
      let userConnectionJson = playlistJson["userConnection"] as? [String: Any],
      let userConnection = PlaylistUser(json: userConnectionJson),
      let tracksCollectionJson = playlistJson["tracksCollection"] as? [String: Any],
      let tracksCollection = PlaylistTracksCollection(json: tracksCollectionJson)
    else {
      return nil
    }
    self.id = id
    self.title = title
    self.description = playlistJson["description"] as? String
    self.artworkUrl = playlistJson["artworkUrl"] as? String
    self.tracksCount = tracksCount
    self.userConnection = userConnection
    self.tracksCollection = tracksCollection
  }
}

extension Playlist: BigPlaylistRenderable {}

struct PlaylistUser {
  let id: String
  let username: String
  let avatarUrl: String?
  let permalinkUrl: String
}

extension PlaylistUser: GraphQLObject {
  init?(json: [String: Any]) {
    guard let id = json["id"] as? String,
      let username = json["username"] as? String,
      let permalinkUrl = json["permalinkUrl"] as? String else {
      return nil
    }
    self.id = id
    self.username = username
    self.avatarUrl = json["avatarUrl"] as? String
    self.permalinkUrl = permalinkUrl
  }
}

extension PlaylistUser: UserRenderable {}

struct PlaylistTracksCollection {
  let collection: [PlaylistTrack]
  let next: String?
}

extension PlaylistTracksCollection: GraphQLObject {
  init?(json: [String: Any]) {
    guard let collectionJson = json["collection"] as? [[String: Any]] else {
      return nil
    }
    self.collection = collectionJson.map { PlaylistTrack(json: $0)! }
    self.next = json["next"] as? String
  }
}

struct PlaylistTrack {
  let id: String
  let title: String
  let permalinkUrl: String
  let artworkUrl: String?
  let duration: Int
}

extension PlaylistTrack: GraphQLObject {
  init?(json: [String: Any]) {
    guard let id = json["id"] as? String,
      let title = json["title"] as? String,
      let permalinkUrl = json["permalinkUrl"] as? String,
      let duration = json["duration"] as? Int else {
      return nil
    }
    self.id = id
    self.title = title
    self.permalinkUrl = permalinkUrl
    self.artworkUrl = json["artworkUrl"] as? String
    self.duration = duration
  }
}

extension PlaylistTrack: TrackRenderable {}
