//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "Test", code: 0)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(),
                  statusCode: statusCode,
                  httpVersion: nil,
                  headerFields: nil)!
    }
}
