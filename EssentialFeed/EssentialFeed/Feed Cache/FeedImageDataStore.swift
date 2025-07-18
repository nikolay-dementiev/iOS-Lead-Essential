//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
