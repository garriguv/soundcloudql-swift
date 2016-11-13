import Foundation

struct PostedTracksQuery: GraphQLCollectionQuery {
  typealias Object = PostedTracks

  let name = "posted_tracks"
  let variables: [String: Any]

  init(id: String, limit: Int, next: String? = nil) {
    var variables: [String: Any] = ["id": id, "limit" : limit ]
    if let next = next {
      variables["next"] = next
    }
    self.variables = variables
  }
}

struct PostedTracks {
  let user: PostedTracksUser
}

extension PostedTracks: GraphQLObject {
  init?(json: [String: Any]) {
    guard let userJson = json["user"] as? [String: Any],
    let user = PostedTracksUser(json: userJson) else {
      return nil
    }
    self.user = user
  }
}

extension PostedTracks: GraphQLCollectionObject {
  typealias Object = Track

  func numberOfItems() -> Int {
    return user.postedTracksCollection.collection.count
  }

  func itemAtIndexPath(_ indexPath: IndexPath) -> Track {
    return user.postedTracksCollection.collection[indexPath.row]
  }

  func next() -> String? {
    return user.postedTracksCollection.next
  }

  func appendObjects(_ object: PostedTracks) -> PostedTracks {
    let tracksCollection = user.postedTracksCollection.collection + object.user.postedTracksCollection.collection
    let collection = UserPostedTracksCollection(collection: tracksCollection, next: object.user.postedTracksCollection.next)
    let _user = PostedTracksUser(postedTracksCollection: collection)
    return PostedTracks(user: _user)
  }
}


struct PostedTracksUser {
  let postedTracksCollection: UserPostedTracksCollection
}

extension PostedTracksUser: GraphQLObject {
  init?(json: [String:Any]) {
    guard let postedTracksCollectionJson = json["postedTracksCollection"] as? [String: Any],
      let postedTracksCollection = UserPostedTracksCollection(json: postedTracksCollectionJson) else {
      return nil
    }
    self.postedTracksCollection = postedTracksCollection
  }
}
