//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
