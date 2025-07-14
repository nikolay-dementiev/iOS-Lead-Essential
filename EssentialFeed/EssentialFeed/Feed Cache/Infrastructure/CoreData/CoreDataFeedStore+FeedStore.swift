//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

extension CoreDataFeedStore: FeedStore {
    /*
    public func retrieve(completion: @escaping RetrievalCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }
    */
    public func retrieve() throws -> CachedFeed? {
        try ManagedCache.find(in: context).map {
            CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
        }
    }
    
    /*
    public func insert(_ feed: [LocalFeedImage],
                       timestamp timestamp: Date,
                       completion: @escaping InsertionCompletion) {
        performAsync { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
            }.mapError {
                context.rollback()
                return $0
            })
        }
    }
    */
    public func insert(_ feed: [LocalFeedImage],
                       timestamp: Date) throws {
        let managedCache = try ManagedCache.newUniqueInstance(in: context)
        managedCache.timestamp = timestamp
        managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    /*
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.deleteCache(in: context)
            }.mapError {
                context.rollback()
                return $0
            })
        }
    }
    */
    public func deleteCachedFeed() throws {
        do {
            try ManagedCache.deleteCache(in: context)
        } catch {
            context.rollback()
            throw error
        }
    }
}
