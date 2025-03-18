//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }//.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getformURL_createsDataTaskWithURL() {
        let url = URL(string: "https://example.com")!
        let session = URLSessionSpy()
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        XCTAssertEqual(session.recievedURLs, [url])
    }
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var recievedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            
            recievedURLs.append(url)
            
            return FaKeURLSessionDataTask()
        }
        
        private class FaKeURLSessionDataTask: URLSessionDataTask {
            
        }
    }
}
