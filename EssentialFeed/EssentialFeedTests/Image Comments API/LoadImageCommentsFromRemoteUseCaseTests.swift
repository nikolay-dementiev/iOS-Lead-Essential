//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    
    func test_load_deliversErrorOnNon2xxHttpResponse() {
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)
        
        let samples = [199, 150, 300, 400, 500]
            
        samples
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
    
    func test_load_deliversErrorOn2xxHttpResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 250, 280, 299]
        
        samples
            .enumerated()
            .forEach { ind, code in
                expect(sut,
                       toCompleteWithResult: failure(.invalidData)) {
                    let invalidJSON = Data("Invalid JSON".utf8)
                    client.complete(withStatusCode: code,
                                    data: invalidJSON,
                                    at: ind)
                }
            }
    }
    
    func test_load_deliversNoItems2xxTTPResponsethEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 250, 280, 299]
        
        samples
            .enumerated()
            .forEach { ind, code in
                expect(sut,
                       toCompleteWithResult: .success([])) {
                    let emptyListJSON = makeItemsJSON([])
                    client.complete(withStatusCode: code,
                                    data: emptyListJSON,
                                    at: ind)
                }
            }
    }
    
    func test_load_deleversItemsOn2xxHTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(),
                             message: "a message",
                             createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                             userName: "a user name")

        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            userName: "another username")
        
        let items = [item1.model, item2.model]
        
        let samples = [200, 201, 250, 280, 299]
        
        samples
            .enumerated()
            .forEach { ind, code in
                
                expect(sut,
                       toCompleteWithResult: .success(items)) {
                    let json = makeItemsJSON([item1.json,
                                              item2.json])
                    client.complete(withStatusCode: code,
                                    data: json,
                                    at: ind)
                }
            }
    }
    
    // MARK: Helpers
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        .failure(error)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeItem(id: UUID,
                          message: String,
                          createdAt: (date: Date, iso8601String: String),
                          userName: String) -> (model: ImageComment, json: [String: Any]) {
        
        let item = ImageComment(id: id,
                                message: message,
                                createdAt: createdAt.date,
                                authorName: userName)
        let itemJson: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": userName
            ]
        ]
        
        return (item, itemJson)
    }
    
    private func expect(_ sut: RemoteImageCommentsLoader,
                        toCompleteWithResult expectedResult: RemoteImageCommentsLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion.")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
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
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)
        
        var capturedResults = [RemoteImageCommentsLoader.Result]()
        sut?.load {
            capturedResults.append($0)
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    private func makeSUT(url: URL = URL(string: "https://example.com")!,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let clientSpy = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: clientSpy)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(clientSpy, file: file, line: line)

        
        return (sut, clientSpy)
    }


}
