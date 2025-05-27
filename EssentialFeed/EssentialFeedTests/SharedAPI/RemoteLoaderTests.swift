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
    
    func test_load_deliversErrorOnNon200HttpResponse() {
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)
        
        [199, 201, 300, 400, 500]
            .enumerated()
            .forEach { ind, code in
                expect(sut, toCompleteWithResult: failure(.invalidData)) {
                    let json = makeItemsJSON([])
                    client.complete(withStatusCode: code,
                                    data: json,
                                    at: ind)
                }
            }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWithResult: failure(.invalidData)) {
            let invalidJSON = Data("Invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItems200TTPResponsethEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWithResult: .success([])) {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deleversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(),
                            imageURL: URL(string: "http://a-url.com")!)

        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "http://b-url.com")!)

        expect(sut,
               toCompleteWithResult: .success([item1.model,
                                               item2.model])) {
            let json = makeItemsJSON([item1.json,
                                      item2.json])
            client.complete(withStatusCode: 200,
                            data: json)
        }
    }
    
    // MARK: Helpers
    
    private func failure(_ error: RemoteLoader.Error) -> RemoteLoader.Result {
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
    
    private func expect(_ sut: RemoteLoader,
                        toCompleteWithResult expectedResult: RemoteLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion.")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteLoader.Error), .failure(expectedError as RemoteLoader.Error)):
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
        var sut: RemoteLoader? = RemoteLoader(url: url, client: client)
        
        var capturedResults = [RemoteLoader.Result]()
        sut?.load {
            capturedResults.append($0)
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    private func makeSUT(url: URL = URL(string: "https://example.com")!,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteLoader, client: HTTPClientSpy) {
        let clientSpy = HTTPClientSpy()
        let sut = RemoteLoader(url: url, client: clientSpy)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(clientSpy, file: file, line: line)

        
        return (sut, clientSpy)
    }
}
