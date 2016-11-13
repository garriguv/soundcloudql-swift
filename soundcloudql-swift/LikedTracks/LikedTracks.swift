import Foundation

struct LikedTracksQuery: GraphQLCollectionQuery {
  typealias Object = LikedTracks

  let name = "liked_tracks"
  let variables: [String: Any]

  init(id: String, limit: Int, next: String? = nil) {
    var variables: [String: Any] = ["id": id, "limit" : limit ]
    if let next = next {
      variables["next"] = next
    }
    self.variables = variables
  }
}

struct LikedTracks {
  let user: LikedTracksUser
}

extension LikedTracks: GraphQLObject {
  init?(json: [String: Any]) {
    guard let userJson = json["user"] as? [String: Any],
    let user = LikedTracksUser(json: userJson) else {
      return nil
    }
    self.user = user
  }
}

extension LikedTracks: GraphQLCollectionObject {
  typealias Object = Track

  func numberOfItems() -> Int {
    return user.likedTracksCollection.collection.count
  }

  func itemAtIndexPath(_ indexPath: IndexPath) -> Track {
    return user.likedTracksCollection.collection[indexPath.row]
  }

  func next() -> String? {
    return user.likedTracksCollection.next
  }

  func appendObjects(_ object: LikedTracks) -> LikedTracks {
    let tracksCollection = user.likedTracksCollection.collection + object.user.likedTracksCollection.collection
    let collection = UserLikedTracksCollection(collection: tracksCollection, next: object.user.likedTracksCollection.next)
    let _user = LikedTracksUser(likedTracksCollection: collection)
    return LikedTracks(user: _user)
  }
}

struct LikedTracksUser {
  let likedTracksCollection: UserLikedTracksCollection
}

extension LikedTracksUser: GraphQLObject {
  init?(json: [String:Any]) {
    guard let likedTracksCollectionJson = json["likedTracksCollection"] as? [String: Any],
    let likedTracksCollection = UserLikedTracksCollection(json: likedTracksCollectionJson) else {
      return nil
    }
    self.likedTracksCollection = likedTracksCollection
  }
}
