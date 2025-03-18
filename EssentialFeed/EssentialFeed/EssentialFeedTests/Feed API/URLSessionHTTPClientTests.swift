//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed

protocol HTTPSEssion {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSEssionTask
}

protocol HTTPSEssionTask {
    func resume()
}

class URLSessionHTTPClient {
    private let session: HTTPSEssion
    
    init(session: HTTPSEssion) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getformURL_resumeskDataTaskWithURL() {
        let url = URL(string: "https://example.com")!
        let session = HTTPSEssionSpy()
        
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { _ in }
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    func test_getfromURL_failsnRequestError() {
        let url = URL(string: "https://example.com")!
        let session = HTTPSEssionSpy()
        
        let error = NSError(domain: "Test", code: 0)
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, error : error)
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as  NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), but got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    private class HTTPSEssionSpy: HTTPSEssion {
        private var stubs = [URL: Stub]()
        private struct Stub {
            let task: HTTPSEssionTask
            let error: Error?
        }
        
        func stub(url: URL,
                  task: HTTPSEssionTask = URLSessionDataTaskSpy(),
                  error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSEssionTask {
            
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for \(url)")
            }
            
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
//    private class FaKeURLSessionDataTask: HTTPSEssionTask {
//        func resume() {
//            
//        }
//    }
    
    private class URLSessionDataTaskSpy: HTTPSEssionTask {
        var resumeCount = 0
        
        func resume() {
            resumeCount += 1
        }
    }
}
