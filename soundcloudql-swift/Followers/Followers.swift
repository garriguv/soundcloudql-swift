import Foundation

struct FollowersQuery: GraphQLCollectionQuery {
  typealias Object = Followers

  let name = "followers"
  let variables: [String: AnyObject]

  init(id: String, limit: Int, next: String? = nil) {
    var variables: [String: AnyObject] = ["id": id, "limit" : limit ]
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
  init?(json: [String:AnyObject]) {
    guard let userJson = json["user"] as? [String: AnyObject],
    let user = FollowersUser(json: userJson) else {
      return nil
    }
    self.user = user
  }
}

extension Followers: GraphQLCollectionObject {
  func appendObjects(object: Followers) -> Followers {
    let followersCollection = user.followersCollection.collection + object.user.followersCollection.collection
    let collection = FollowersUserFollowersCollection(collection: followersCollection, next: object.user.followersCollection.next)
    let _followersUser = FollowersUser(followersCollection: collection)
    return Followers(user: _followersUser)
  }

  func next() -> String? {
    return user.followersCollection.next
  }

  func itemAtIndexPath(indexPath: NSIndexPath) -> FollowersMiniUser {
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
  init?(json: [String:AnyObject]) {
    guard let followersCollectionJson = json["followersCollection"] as? [String: AnyObject],
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
  init?(json: [String: AnyObject]) {
    guard let collection = json["collection"] as? [[String: AnyObject]] else {
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
  init?(json: [String: AnyObject]) {
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
