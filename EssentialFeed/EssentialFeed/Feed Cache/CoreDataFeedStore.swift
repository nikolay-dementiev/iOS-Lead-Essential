//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init() {}

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insert(_ feed: [LocalFeedImage], timeStamp timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }
}
