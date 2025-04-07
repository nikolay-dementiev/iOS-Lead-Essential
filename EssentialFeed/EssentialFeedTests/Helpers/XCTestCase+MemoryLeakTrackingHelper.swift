//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeacks(_ ins: AnyObject,
                              file: StaticString = #filePath,
                              line: UInt = #line) {
        addTeardownBlock { [weak ins] in
            XCTAssertNil(ins,
                         "Instance should be dealocated. Potentially it's memory leak.",
                         file: file,
                         line: line)
        }
    }
}
