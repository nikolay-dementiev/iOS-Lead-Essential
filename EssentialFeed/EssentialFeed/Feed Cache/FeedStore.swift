//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedItem], timeStamp: Date, completion: @escaping InsertionCompletion)
}
