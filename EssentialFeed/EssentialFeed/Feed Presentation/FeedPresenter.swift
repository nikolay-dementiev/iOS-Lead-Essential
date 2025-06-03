//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import Foundation

public final class FeedPresenter {
    
    public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the Feed view")
    }
    
    private var feedLoadError: String {
        NSLocalizedString("GENERIC_CONNECTION_ERROR",
                          tableName: "Shared",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
