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
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_TwiceRequestsDataFromURLTwice() {
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
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
    
    func test_load_deliversErrorOnNon200HttpResponse() {
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)
        
        
        
        let clientError = NSError(domain: "Test", code: 0)
        [199, 201, 300, 400, 500]
            .enumerated()
            .forEach { ind, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load {
                capturedErrors.append($0)
            }
            
            client.complete(withStatusCode: code, at: ind)
            
            XCTAssertEqual(capturedErrors,
                           [.invalidData])
        }
    }
    
    // MARK: Helpers
    private func makeSUT(url: URL = URL(string: "https://example.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let clientSpy = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: clientSpy)
        
        return (sut, clientSpy)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        private var messages = [(url: URL, completion: (Error?, URLResponse?) -> Void)]()
        
        func get(from url: URL,
                 completion: @escaping (Error?, URLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at ind: Int = 0) {
            messages[ind].completion(error, nil)
        }
        
        func complete(withStatusCode code: Int, at ind: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[ind],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)
            
            messages[ind].completion(nil, response)
        }
    }
}
