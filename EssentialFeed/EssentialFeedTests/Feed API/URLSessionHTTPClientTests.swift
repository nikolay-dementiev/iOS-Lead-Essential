//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performGetRequestWithURL() {
        let url = anyURL()
        
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 0.3)
    }
    
    func test_getfromURL_failsOnRequestError() {
        let requestError = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual((receivedError as? NSError)?.code, requestError.code)
        XCTAssertEqual((receivedError as? NSError)?.domain, requestError.domain)
    }
    
    func test_getfromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyNonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyNonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyNonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyNonHTTPURLResponse(), error: nil))
    }
    
    func test_getfromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let recievedValues = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(recievedValues?.data, data)
        XCTAssertEqual(recievedValues?.response.url, response.url)
        XCTAssertEqual(recievedValues?.response.statusCode, response.statusCode)
    }
    
    func test_getfromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        let recievedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(recievedValues?.data, emptyData)
        XCTAssertEqual(recievedValues?.response.url, response.url)
        XCTAssertEqual(recievedValues?.response.statusCode, response.statusCode)
    }
    
    // MARK: - Helpers
    private func resultValuesFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #filePath,
                                 line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected success, but got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #filePath,
                                line: UInt = #line) -> Error? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, but got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?,
                           response: URLResponse?,
                           error: Error?,
                           file: StaticString = #filePath,
                           line: UInt = #line) -> HTTPClient.Result {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        
        var receivedResult: HTTPClient.Result!
        let exp = expectation(description: "Wait for completion")
        sut.get(from: anyURL()) { result in
            receivedResult = result
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.3)
        
        return receivedResult
    }
        
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }
    
    private func anyNonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeacks(sut, file: file, line: line)
        
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var observeRequests: ((URLRequest) -> Void)?
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            observeRequests = nil
        }
        
        static func stub(data: Data?,
                         response: URLResponse?,
                         error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            observeRequests = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            if let requestObserver = URLProtocolStub.observeRequests {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
}
