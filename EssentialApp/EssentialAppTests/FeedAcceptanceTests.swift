//
//  EssentialAppTests
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class FeedAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertTrue(feed.canLoadMoreFeed)
        
        feed.simulateLoadMoreFeedAction()
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 3)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData2())
        XCTAssertTrue(feed.canLoadMoreFeed)
        
        feed.simulateLoadMoreFeedAction()
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 3)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData2())
        XCTAssertFalse(feed.canLoadMoreFeed)
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
        
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        
        onlineFeed.simulateLoadMoreFeedAction()
        onlineFeed.simulateFeedImageViewVisible(at: 2)
        
        let offlineFeed = launch(httpClient: .offline, store: sharedStore)
        
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 3)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 2), makeImageData2())
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
    }
    
    
    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }
    
    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
    }
    
    func test_onFeedImageSelection_displayComments() {
        let comments = showCommentsForFirstImage()
        comments.simulateAppearance()
        XCTAssertEqual(comments.numberOfRenderedComments(), 1)
        XCTAssertEqual(comments.commentMessage(at: 0), createCommentMessage())
    }
    
    // MARK: - Helpers
    
    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryFeedStore = .empty
    ) -> ListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        let feedController = nav?.topViewController as! ListViewController
        
        feedController.simulateAppearance()
        
        return feedController
    }
    
    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private func showCommentsForFirstImage() -> ListViewController {
        let feed = launch(httpClient: .online(response), store: .empty)
        
        feed.simulateTapOnFeedImage(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = feed.navigationController
        
        return nav?.topViewController as! ListViewController
    }
    
    private class HTTPClientStub: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        private let stub: (URL) -> HTTPClient.Result
        
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
        }
        
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url)) }
        }
    }
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.path {
        case "/image-0":
            return makeImageData0()
        case "/image-1":
            return makeImageData1()
        case "/image-2":
            return makeImageData2()
            
        case "/essential-feed/v1/feed" where url.query?.contains("after_id") == false:
            return makeFirstFeedPageData()
        case "/essential-feed/v1/feed" where url.query?.contains("after_id=\(secondPageId)") == true:
            return makeSecondFeedPageData()
            
        case "/essential-feed/v1/feed" where url.query?.contains("after_id=\(thirdPageId)") == true:
            return makeLastEmptyFeedPageData()
            
        case "/essential-feed/v1/image/\(firsPageId)/comments":
            return makeCommentsData()
            
        default:
            return Data()
        }
    }
    
    private func makeImageData0() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeImageData1() -> Data {
        return UIImage.make(withColor: .yellow).pngData()!
    }
    
    private func makeImageData2() -> Data {
        return UIImage.make(withColor: .green).pngData()!
    }
    
    var firsPageId: String = "2AB2AE66-A4B7-4A16-B374-51BBAC8DB086"
    var secondPageId: String = "A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A"
    var thirdPageId: String = "AA0C1997-F675-4FBB-8C7B-07D059D3C793"

    private func makeFirstFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": firsPageId, "image": "http://feed.com/image-0"],
            ["id": secondPageId, "image": "http://feed.com/image-1"]
        ]])
    }
    
    private func makeSecondFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": thirdPageId, "image": "http://feed.com/image-2"]
        ]])
    }
    
    private func makeLastEmptyFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": []])
    }
    
    private func makeCommentsData() -> Data {
        return try! JSONSerialization.data(
            withJSONObject: ["items": [
                [
                    "id": UUID().uuidString,
                    "message": createCommentMessage(),
                    "created_at": "2023-10-01T12:00:00Z",
                    "author": [
                        "username": "a username"
                    ]
                ]
            ]]
        )
    }
    
    private func createCommentMessage() -> String {
        "a username"
    }
}
