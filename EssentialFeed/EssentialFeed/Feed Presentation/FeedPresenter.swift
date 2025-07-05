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
                          bundle: Bundle(for: Self.self),
                          comment: "Title for the Feed view")
    }
}
