import Foundation

struct ProfileQuery: GraphQLQuery {
  typealias Object = Profile

  let name = "profile"
  let variables: [String: String]

  init(profileID: String) {
    self.variables = [ "id": profileID ]
  }
}

struct Profile {
  let user: User
}

extension Profile: GraphQLObject {
  init?(json: [String: AnyObject]) {
    guard let userJson = json["user"] as? [String: AnyObject],
    let user = User(json: userJson) else {
      return nil
    }
    self.user = user
  }
}

struct User {
  let id: String
  let username: String
  let permalinkUrl: String
  let city: String?
  let avatarUrl: String?
  let postedTracksCollection: UserPostedTracksCollection
  let likedTracksCollection: UserLikedTracksCollection
}

extension User: GraphQLObject {
  init?(json: [String: AnyObject]) {
    guard let id = json["id"] as? String,
    let username = json["username"] as? String,
    let permalinkUrl = json["permalinkUrl"] as? String,
    let postedTracksCollectionJson = json["postedTracksCollection"] as? [String: AnyObject],
    let postedTracksCollection = UserPostedTracksCollection(json: postedTracksCollectionJson),
    let likedTracksCollectionJson = json["likedTracksCollection"] as? [String: AnyObject],
    let likedTracksCollection = UserLikedTracksCollection(json: likedTracksCollectionJson) else {
      return nil
    }
    self.id = id
    self.username = username
    self.permalinkUrl = permalinkUrl
    self.city = json["city"] as? String
    self.avatarUrl = json["avatarUrl"] as? String
    self.postedTracksCollection = postedTracksCollection
    self.likedTracksCollection = likedTracksCollection
  }
}

struct UserPostedTracksCollection {
  let collection: [Track]
  let next: String?
}

extension UserPostedTracksCollection: GraphQLObject {
  init?(json: [String: AnyObject]) {
    guard let collection = json["collection"] as? [[String: AnyObject]] else {
      return nil
    }
    self.collection = collection.map { Track(json: $0)! }
    self.next = json["next"] as? String
  }
}

struct UserLikedTracksCollection {
  let collection: [Track]
  let next: String?
}

extension UserLikedTracksCollection: GraphQLObject {
  init?(json: [String: AnyObject]) {
    guard let collection = json["collection"] as? [[String: AnyObject]] else {
      return nil
    }
    self.collection = collection.map { Track(json: $0)! }
    self.next = json["next"] as? String
  }
}

struct Track {
  let id: String
  let title: String
  let permalinkUrl: String
  let artworkUrl: String?
}

extension Track: GraphQLObject {
  init?(json: [String: AnyObject]) {
    guard let id = json["id"] as? String,
    let title = json["title"] as? String,
    let permalinkUrl = json["permalinkUrl"] as? String else {
      return nil
    }
    self.id = id
    self.title = title
    self.permalinkUrl = permalinkUrl
    self.artworkUrl = json["artworkUrl"] as? String
  }
}
