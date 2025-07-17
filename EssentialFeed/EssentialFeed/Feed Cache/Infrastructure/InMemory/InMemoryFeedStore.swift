//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//


//
//  EssentialApp
//
//  Created by Mykola Dementiev
//

import Foundation

public class InMemoryFeedStore {
    private(set) var feedCache: CachedFeed?
    private var feedImageDataCache: [URL: Data] = [:]
    
    public init() {}
    
    private init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
}

extension InMemoryFeedStore: FeedStore {
    /*
     func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
     feedCache = nil
     completion(.success(()))
     }
     */
    public func deleteCachedFeed() throws {
        feedCache = nil
    }
    
    /*
     func insert(_ feed: [LocalFeedImage], timestamp timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
     feedCache = CachedFeed(feed: feed, timestamp: timestamp)
     completion(.success(()))
     }
     */
    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        feedCache = CachedFeed(feed: feed, timestamp: timestamp)
    }
    
    /*
     func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
     completion(.success(feedCache))
     }
     */
    public func retrieve() throws -> CachedFeed? {
        feedCache
    }
}

extension InMemoryFeedStore: FeedImageDataStore {
       
    public func insert(_ data: Data, for url: URL) throws {
        feedImageDataCache[url] = data
    }
    
    public func retrieve(dataForURL url: URL) throws -> Data? {
        feedImageDataCache[url]
    }
}

extension InMemoryFeedStore {
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
    }
}
