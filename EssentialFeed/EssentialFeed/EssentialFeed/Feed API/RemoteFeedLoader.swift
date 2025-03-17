//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = LoadFeedResult<Error>
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL,
         client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(commpletion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                commpletion(FeedItemsMapper.map(data, from: response))
            case .failure:
                commpletion(.failure(.connectivity))
            }
        }
    }
}

