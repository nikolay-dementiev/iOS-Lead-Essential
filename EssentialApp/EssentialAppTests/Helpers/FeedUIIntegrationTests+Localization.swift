import Foundation
import XCTest
import EssentialFeediOS
import EssentialFeed

extension FeedUIIntegrationTests {
    var loadError: String {
        LoadResourcePresenter<Any, DumyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
    
    private class DumyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}


extension CommentsUIIntegrationTests {
    var commentsTitle: String {
        ImageCommentsPresenter.title
    }
}
