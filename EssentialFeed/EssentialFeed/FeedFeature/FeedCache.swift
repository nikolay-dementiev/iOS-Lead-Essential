//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
