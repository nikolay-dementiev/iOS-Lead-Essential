//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(complertion: @escaping (LoadFeedResult) -> Void)
}
