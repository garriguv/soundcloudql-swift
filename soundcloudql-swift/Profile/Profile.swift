import Foundation

struct ProfileQuery: GraphQLQuery {
  typealias Object = Profile

  let name = "profile"
  let variables: [String: AnyObject]

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
  let followersCount: Int
  let followingsCount: Int
  let postedTracksCollection: UserPostedTracksCollection
  let likedTracksCollection: UserLikedTracksCollection
  let postedPlaylistsCollection: UserPostedPlaylistsCollection
}

extension User: GraphQLObject {
  init?(json: [String: AnyObject]) {
    guard let id = json["id"] as? String,
    let username = json["username"] as? String,
    let permalinkUrl = json["permalinkUrl"] as? String,
    let followersCount = json["followersCount"] as? Int,
    let followingsCount = json["followingsCount"] as? Int,
    let postedTracksCollectionJson = json["postedTracksCollection"] as? [String: AnyObject],
    let postedTracksCollection = UserPostedTracksCollection(json: postedTracksCollectionJson),
    let likedTracksCollectionJson = json["likedTracksCollection"] as? [String: AnyObject],
    let likedTracksCollection = UserLikedTracksCollection(json: likedTracksCollectionJson),
    let postedPlaylistsCollectionJson = json["postedPlaylistsCollection"] as? [String: AnyObject],
    let postedPlaylistsCollection = UserPostedPlaylistsCollection(json: postedPlaylistsCollectionJson) else {
      return nil
    }
    self.id = id
    self.username = username
    self.permalinkUrl = permalinkUrl
    self.city = json["city"] as? String
    self.avatarUrl = json["avatarUrl"] as? String
    self.followersCount = followersCount
    self.followingsCount = followingsCount
    self.postedTracksCollection = postedTracksCollection
    self.likedTracksCollection = likedTracksCollection
    self.postedPlaylistsCollection = postedPlaylistsCollection
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

struct UserPostedPlaylistsCollection {
  let collection: [Playlist]
  let next: String?
}

extension UserPostedPlaylistsCollection: GraphQLObject {
  init?(json: [String: AnyObject]) {
    guard let collection = json["collection"] as? [[String: AnyObject]] else {
      return nil
    }
    self.collection = collection.map { Playlist(json: $0)! }
    self.next = json["next"] as? String
  }
}

struct Track {
  let id: String
  let title: String
  let permalinkUrl: String
  let artworkUrl: String?
  let duration: Int
}

extension Track: GraphQLObject {
  init?(json: [String: AnyObject]) {
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

struct Playlist {
  let id: String
  let title: String
  let permalinkUrl: String
  let artworkUrl: String?
  let tracksCount: Int
  let duration: Int
}

extension Playlist: GraphQLObject {
  init?(json: [String: AnyObject]) {
    guard let id = json["id"] as? String,
    let title = json["title"] as? String,
    let permalinkUrl = json["permalinkUrl"] as? String,
    let tracksCount = json["tracksCount"] as? Int,
    let duration = json["duration"] as? Int else {
      return nil
    }
    self.id = id
    self.title = title
    self.permalinkUrl = permalinkUrl
    self.artworkUrl = json["artworkUrl"] as? String
    self.tracksCount = tracksCount
    self.duration = duration
  }
}
