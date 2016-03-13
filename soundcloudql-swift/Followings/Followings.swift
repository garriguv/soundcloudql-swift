import Foundation

struct FollowingsQuery: GraphQLCollectionQuery {
  typealias Object = Followings

  let name = "followings"
  let variables: [String: AnyObject]

  init(id: String, limit: Int, next: String? = nil) {
    var variables: [String: AnyObject] = [ "id": id, "limit" : limit ]
    if let next = next {
      variables["next"] = next
    }
    self.variables = variables
  }
}

struct Followings {
  let user: FollowingsUser
}

extension Followings: GraphQLObject {
  init?(json: [String:AnyObject]) {
    guard let userJson = json["user"] as? [String: AnyObject],
    let user = FollowingsUser(json: userJson) else {
      return nil
    }
    self.user = user
  }
}

extension Followings: GraphQLCollectionObject {
  func appendObjects(object: Followings) -> Followings {
    let followingsCollection = user.followingsCollection.collection + object.user.followingsCollection.collection
    let collection = FollowingsUserFollowingsCollection(collection: followingsCollection, next: object.user.followingsCollection.next)
    let _followingsUser = FollowingsUser(followingsCollection: collection)
    return Followings(user: _followingsUser)
  }

  func next() -> String? {
    return user.followingsCollection.next
  }

  func itemAtIndexPath(indexPath: NSIndexPath) -> FollowingsMiniUser {
    return user.followingsCollection.collection[indexPath.row]
  }

  func numberOfItems() -> Int {
    return user.followingsCollection.collection.count
  }
}

struct FollowingsUser {
  let followingsCollection: FollowingsUserFollowingsCollection
}

extension FollowingsUser: GraphQLObject {
  init?(json: [String:AnyObject]) {
    guard let followingsCollectionJson = json["followingsCollection"] as? [String: AnyObject],
    let followingsCollection = FollowingsUserFollowingsCollection(json: followingsCollectionJson) else {
      return nil
    }
    self.followingsCollection = followingsCollection
  }
}

struct FollowingsUserFollowingsCollection {
  let collection: [FollowingsMiniUser]
  let next: String?
}

extension FollowingsUserFollowingsCollection: GraphQLObject {
  init?(json: [String: AnyObject]) {
    guard let collection = json["collection"] as? [[String: AnyObject]] else {
      return nil
    }
    self.collection = collection.map { FollowingsMiniUser(json: $0)! }
    self.next = json["next"] as? String
  }
}

struct FollowingsMiniUser {
  let id: String
  let username: String
  let avatarUrl: String?
}

extension FollowingsMiniUser: GraphQLObject {
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

extension FollowingsMiniUser: UserRenderable {}
