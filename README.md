# SoundCloudQL-Swift [![Build Status](https://travis-ci.org/garriguv/soundcloudql-swift.svg?branch=master)](https://travis-ci.org/garriguv/soundcloudql-swift)

iOS client for [SoundCloudQL].

### Getting started

Install the dependencies:

    ./scripts/bootstrap

Run [SoundCloudQL] locally or deploy it to Heroku. Update `graphql_url` in [Environment.plist](https://github.com/garriguv/soundcloudql-swift/blob/master/soundcloudql-swift/Api/Environment.plist.sample) if needed:

    cp soundcloudql-swift/Api/Environment.plist.sample soundcloudql-swift/Api/Environment.plist
    open soundcloudql-swift/Api/Environment.plist

### Testing

    bundle exec fastlane test

[SoundCloudQL]: https://github.com/garriguv/soundcloudql
