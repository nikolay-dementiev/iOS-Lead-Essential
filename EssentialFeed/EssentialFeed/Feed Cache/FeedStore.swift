//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
    /// The completion block can be invoked on any thread.
    /// Client is responsible for dispatching to appropriate thread if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion block can be invoked on any thread.
    /// Client is responsible for dispatching to appropriate thread if needed.
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion block can be invoked on any thread.
    /// Client is responsible for dispatching to appropriate thread if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
