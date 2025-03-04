//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestsDataFromUrl() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_RequestsDataFromURL() {
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_TwiceRequestsDataFromURLTwice() {
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)
        
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load {
            capturedErrors.append($0)
        }
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors,
                       [.connectivity])
    }
    
    // MARK: Helpers
    private func makeSUT(url: URL = URL(string: "https://example.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let clientSpy = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: clientSpy)
        
        return (sut, clientSpy)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        private var messages = [(url: URL, completion: (Error) -> Void)]()
        
        func get(from url: URL,
                 completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at ind: Int = 0) {
            messages[ind].completion(error)
        }
    }
}
