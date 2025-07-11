//
//  EssentialApp
//
//  Created by Mykola Dementiev
//
import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(
        _ feed: [EssentialFeed.LocalFeedImage],
        timeStamp: Date,
        completion: @escaping InsertionCompletion
    ) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func insert(
        _ data: Data,
        for url: URL,
        completion: @escaping (InsertionResult) -> Void
    ) {
        completion(.success(()))
    }
    
    func retrieve(
        dataForURL url: URL,
        completion: @escaping (RetrievalResult) -> Void
    ) {
        completion(.success(.none))
    }
}
