import Foundation

struct PostedPlaylistsQuery: GraphQLCollectionQuery {
  typealias Object = PostedPlaylists

  let name = "posted_playlists"
  let variables: [String: Any]

  init(id: String, limit: Int, next: String? = nil) {
    var variables: [String: Any] = ["id": id, "limit": limit]
    if let next = next {
      variables["next"] = next
    }
    self.variables = variables
  }
}

struct PostedPlaylists {
  let user: PostedPlaylistsUser
}

extension PostedPlaylists: GraphQLObject {
  init?(json: [String: Any]) {
    guard let userJson = json["user"] as? [String: Any],
      let user = PostedPlaylistsUser(json: userJson) else {
      return nil
    }
    self.user = user
  }
}

extension PostedPlaylists: GraphQLCollectionObject {
  typealias Object = MiniPlaylist

  func numberOfItems() -> Int {
    return user.postedPlaylistsCollection.collection.count
  }

  func itemAtIndexPath(_ indexPath: IndexPath) -> MiniPlaylist {
    return user.postedPlaylistsCollection.collection[indexPath.row]
  }

  func next() -> String? {
    return user.postedPlaylistsCollection.next
  }

  func appendObjects(_ object: PostedPlaylists) -> PostedPlaylists {
    let playlistsCollection = user.postedPlaylistsCollection.collection + object.user.postedPlaylistsCollection.collection
    let collection = UserPostedPlaylistsCollection(collection: playlistsCollection, next: object.user.postedPlaylistsCollection.next)
    let _user = PostedPlaylistsUser(postedPlaylistsCollection: collection)
    return PostedPlaylists(user: _user)
  }
}

struct PostedPlaylistsUser {
  let postedPlaylistsCollection: UserPostedPlaylistsCollection
}

extension PostedPlaylistsUser: GraphQLObject {
  init?(json: [String: Any]) {
    guard let postedPlaylistsCollectionJson = json["postedPlaylistsCollection"] as? [String: Any],
      let postedPlaylistsCollection = UserPostedPlaylistsCollection(json: postedPlaylistsCollectionJson) else {
      return nil
    }
    self.postedPlaylistsCollection = postedPlaylistsCollection
  }
}
