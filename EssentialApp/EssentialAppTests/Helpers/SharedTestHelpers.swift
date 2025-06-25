//
//  EssentialAppTests
//
//  Created by Mykola Dementiev
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}

var loadError: String {
    LoadResourcePresenter<Any, DumyView>.loadError
}

var feedTitle: String {
    FeedPresenter.title
}

private class DumyView: ResourceView {
    func display(_ viewModel: Any) {}
}

var commentsTitle: String {
    ImageCommentsPresenter.title
}
