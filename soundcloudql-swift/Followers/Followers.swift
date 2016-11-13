import Foundation

struct FollowersQuery: GraphQLCollectionQuery {
  typealias Object = Followers

  let name = "followers"
  let variables: [String: Any]

  init(id: String, limit: Int, next: String? = nil) {
    var variables: [String: Any] = ["id": id, "limit" : limit ]
    if let next = next {
      variables["next"] = next
    }
    self.variables = variables
  }
}

struct Followers {
  let user: FollowersUser
}

extension Followers: GraphQLObject {
  init?(json: [String:Any]) {
    guard let userJson = json["user"] as? [String: Any],
    let user = FollowersUser(json: userJson) else {
      return nil
    }
    self.user = user
  }
}

extension Followers: GraphQLCollectionObject {
  func appendObjects(_ object: Followers) -> Followers {
    let followersCollection = user.followersCollection.collection + object.user.followersCollection.collection
    let collection = FollowersUserFollowersCollection(collection: followersCollection, next: object.user.followersCollection.next)
    let _followersUser = FollowersUser(followersCollection: collection)
    return Followers(user: _followersUser)
  }

  func next() -> String? {
    return user.followersCollection.next
  }

  func itemAtIndexPath(_ indexPath: IndexPath) -> FollowersMiniUser {
    return user.followersCollection.collection[indexPath.row]
  }

  func numberOfItems() -> Int {
    return user.followersCollection.collection.count
  }
}

struct FollowersUser {
  let followersCollection: FollowersUserFollowersCollection
}

extension FollowersUser: GraphQLObject {
  init?(json: [String:Any]) {
    guard let followersCollectionJson = json["followersCollection"] as? [String: Any],
    let followersCollection = FollowersUserFollowersCollection(json: followersCollectionJson) else {
      return nil
    }
    self.followersCollection = followersCollection
  }
}

struct FollowersUserFollowersCollection {
  let collection: [FollowersMiniUser]
  let next: String?
}

extension FollowersUserFollowersCollection: GraphQLObject {
  init?(json: [String: Any]) {
    guard let collection = json["collection"] as? [[String: Any]] else {
      return nil
    }
    self.collection = collection.map { FollowersMiniUser(json: $0)! }
    self.next = json["next"] as? String
  }
}

struct FollowersMiniUser {
  let id: String
  let username: String
  let avatarUrl: String?
}

extension FollowersMiniUser: GraphQLObject {
  init?(json: [String: Any]) {
    guard let id = json["id"] as? String,
    let username = json["username"] as? String else {
      return nil
    }
    self.id = id
    self.username = username
    self.avatarUrl = json["avatarUrl"] as? String
  }
}

extension FollowersMiniUser: UserRenderable {}
