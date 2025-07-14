//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
//    func test_save_requestCacheDeletion() {
//        let (sut, store) = makeSUT()
//        sut.save(uniqueImageFeed().models) { _ in }
//        
//        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
//    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletetionError = anyNSError()
        store.completeDeletion(with: deletetionError)
        try? sut.save(uniqueImageFeed().models)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: { timeStamp })
        let feed = uniqueImageFeed()
        
        store.completeDeletionSuccessfully()
        try? sut.save(feed.models)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timeStamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletetionError = anyNSError()
        expect(sut, toCompleteWithError: deletetionError) {
            store.completeDeletion(with: deletetionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_successedOnSuccessfullCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
//    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
//        let store = FeedStoreSpy()
//        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
//        
//        var receivedResulrs = [LocalFeedLoader.SaveResult]()
//        sut?.save(uniqueImageFeed().models) {
//            receivedResulrs.append($0)
//        }
//        
//        sut = nil
//        store.completeDeletion(with: anyNSError())
//        
//        XCTAssertTrue(receivedResulrs.isEmpty)
//    }
    
//    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
//        let store = FeedStoreSpy()
//        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
//        
//        var receivedResulrs = [LocalFeedLoader.SaveResult]()
//        sut?.save([uniqueImage()]) {
//            receivedResulrs.append($0)
//        }
//        
//        store.completeDeletionSuccessfully()
//        sut = nil
//        store.completeDeletion(with: anyNSError())
//        
//        XCTAssertTrue(receivedResulrs.isEmpty)
//    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #file,
                         line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader,
                        toCompleteWithError expectedError: NSError?,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        
        action()
        
        do {
            try sut.save(uniqueImageFeed().models)
        } catch {
            XCTAssertEqual(expectedError, error as? NSError, file: file, line: line)
        }
    }
}
