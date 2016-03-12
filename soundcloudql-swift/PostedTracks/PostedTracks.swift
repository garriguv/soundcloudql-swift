import Foundation

struct PostedTracksQuery: GraphQLQuery {
  typealias Object = PostedTracks

  let name = "posted_tracks"
  let variables: [String: String]

  init(profileID: String, next: String? = nil) {
    var variables = [ "id": profileID ]
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
  init?(json: [String: AnyObject]) {
    guard let userJson = json["user"] as? [String: AnyObject],
    let user = PostedTracksUser(json: userJson) else {
      return nil
    }
    self.user = user
  }
}

struct PostedTracksUser {
  let postedTracksCollection: UserPostedTracksCollection
}

extension PostedTracksUser: GraphQLObject {
  init?(json: [String:AnyObject]) {
    guard let postedTracksCollectionJson = json["postedTracksCollection"] as? [String: AnyObject],
      let postedTracksCollection = UserPostedTracksCollection(json: postedTracksCollectionJson) else {
      return nil
    }
    self.postedTracksCollection = postedTracksCollection
  }
}

