//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed

class RemoteLoaderTests: XCTestCase {

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
        
        expect(sut,
               toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnMappersError() {
        let (sut, client) = makeSUT(mapper: { _, _ in
            throw anyNSError()
        })
        
        expect(sut,
               toCompleteWithResult: failure(.invalidData)) {
            client.complete(withStatusCode: 200, data: anyData())
        }
    }
    
    func test_load_deleversMappedResource() {
        let resource = "a resource"
        let (sut, client) = makeSUT(mapper: { data, _ in
            String(data: data, encoding: .utf8)!
        })

        expect(sut,
               toCompleteWithResult: .success(resource)) {
            client.complete(withStatusCode: 200,
                            data: Data(resource.utf8))
        }
    }
    
    // MARK: Helpers
    
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        .failure(error)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeItem(id: UUID,
                          description: String? = nil,
                          location: String? = nil,
                          imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        
        let feedItem = FeedImage(id: id,
                                description: description,
                                location: location,
                                url: imageURL)
        let itemJson = [
            "id": feedItem.id.uuidString,
            "description": feedItem.description,
            "location": feedItem.location,
            "image": feedItem.url.absoluteString
        ].compactMapValues { $0 }
        
        return (feedItem, itemJson)
    }
    
    private func expect(_ sut: RemoteLoader<String>,
                        toCompleteWithResult expectedResult: RemoteLoader<String>.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion.")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 0.3)
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://example.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client, mapper: { _, _ in "any" })
        
        var capturedResults = [RemoteLoader<String >.Result]()
        sut?.load {
            capturedResults.append($0)
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    private func makeSUT(url: URL = URL(string: "https://example.com")!,
                         mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any" },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
        let clientSpy = HTTPClientSpy()
        let sut = RemoteLoader<String>(url: url, client: clientSpy, mapper: mapper)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(clientSpy, file: file, line: line)

        
        return (sut, clientSpy)
    }
}
