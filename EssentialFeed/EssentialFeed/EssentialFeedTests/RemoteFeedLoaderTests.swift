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
        client.completions[0](clientError)
        
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
        private(set) var requestedURLs = [URL]()
        var completions = [(Error) -> Void]()
        
        func get(from url: URL,
                 completion: @escaping (Error) -> Void) {
            completions.append(completion)
            requestedURLs.append(url)
        }
    }
}
