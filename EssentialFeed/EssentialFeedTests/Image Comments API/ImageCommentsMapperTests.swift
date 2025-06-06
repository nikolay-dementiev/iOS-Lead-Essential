//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed

final class ImageCommentsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHttpResponse() throws {
        let samples = [199, 150, 300, 400, 500]
        
        let json = makeItemsJSON([])
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn2xxHttpResponseWithInvalidJSON() throws {
        let invalidJSON = Data("Invalid JSON".utf8)
        let samples = [200, 201, 250, 280, 299]
        
        try samples
            .forEach { code in
                XCTAssertThrowsError(
                    try ImageCommentsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: code))
                )
            }
    }
    
    func test_map_deliversNoItems2xxHTTPResponsethEmptyJSONList() throws {
        let emptyListJSON = makeItemsJSON([])
        let samples = [200, 201, 250, 280, 299]
        
        try samples
            .forEach { code in
                let result = try ImageCommentsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: code))
                
                XCTAssertEqual(result, [], "Expected empty items array on \(code) response")
            }
    }
    
    func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
        let item1 = makeItem(id: UUID(),
                             message: "a message",
                             createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                             userName: "a user name")
        
        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            userName: "another username")
        
        let json = makeItemsJSON([item1.json,
                                  item2.json])
        let items = [item1.model, item2.model]
        
        let samples = [200, 201, 250, 280, 299]
        
        try samples
            .forEach { code in
                let result = try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: code))
                
                XCTAssertEqual(result, items, "Expected empty items array on \(code) response")
            }
    }
    
    // MARK: Helpers
    
    private func makeItem(id: UUID,
                          message: String,
                          createdAt: (date: Date, iso8601String: String),
                          userName: String) -> (model: ImageComment, json: [String: Any]) {
        
        let item = ImageComment(id: id,
                                message: message,
                                createdAt: createdAt.date,
                                userName: userName)
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
}
