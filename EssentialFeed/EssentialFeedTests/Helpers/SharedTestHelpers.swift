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
    return URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}
