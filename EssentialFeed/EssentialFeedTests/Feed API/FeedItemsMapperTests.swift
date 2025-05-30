//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import EssentialFeed

final class FeedItemsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HttpResponse() throws {
        let json = makeItemsJSON([])
        try [199, 201, 300, 400, 500].forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwErrorOn200HttpResponseWithInvalidJSON() {
        let invalidJSON = Data("Invalid JSON".utf8)
        
        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNoItems200HTTPResponsethEmptyJSONList() throws {
        let emptyListJSON = makeItemsJSON([])
        let result = try FeedItemsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_deleversItemsOn200HTTPResponseWithJSONItems() throws {
        let item1 = makeItem(id: UUID(),
                            imageURL: URL(string: "http://a-url.com")!)

        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "http://b-url.com")!)
        
        let items = [item1, item2]
        let json = makeItemsJSON(items.map { $0.json })
        let result = try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, items.map { $0.model })
    }
    
    // MARK: Helpers
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
}
