//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed

class CodebleFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map {
                $0.local
            }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
        
        init(_ localFeedImage: LocalFeedImage) {
            id = localFeedImage.id
            description = localFeedImage.description
            location = localFeedImage.location
            url = localFeedImage.url
        }
    }
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("feed-image.store")
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage],
                timeStamp: Date,
                completion: @escaping FeedStore.InsertionCompletion) {
        
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timeStamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("feed-image.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrive_deliveersEmptyOnEmptyCache() {
        let sut = CodebleFeedStore()
        let exp = expectation(description: "Retrieval should complete")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, but got: \n\t\(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    func test_retrive_hasNoSideEffectsOnEmptyCache() {
        let sut = CodebleFeedStore()
        let exp = expectation(description: "Retrieval should complete")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty results, but got: \n\t\(firstResult) and \n\t\(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retriveAfterINsertingtoEmptyCache_deliversInsertedValues() {
        let sut = CodebleFeedStore()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        let exp = expectation(description: "Retrieval should complete")
        
        sut.insert(feed, timeStamp: timeStamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(retrievedFeed, retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, feed)
                    XCTAssertEqual(timeStamp, retrievedTimestamp)
                default:
                    XCTFail("Expected found results with \(feed) and \(timeStamp), but got: \(retrieveResult) instead")
                }
                 
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }

}
