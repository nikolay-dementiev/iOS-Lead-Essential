//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest

protocol FeedImageView {
    associatedtype Image

//    func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View
    
    init(view: View) {
        self.view = view
    }
}

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        _ = FeedImagePresenter(view: view)
        XCTAssertTrue(view.messages.isEmpty, "Epected no view mesages")
    }
    
    // MARK: - Helper
    
    private class ViewSpy: FeedImageView {
        typealias Image = Any
        
        var messages = [Any]()
        
    }
}
