//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL,
         client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(commpletion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                commpletion(.failure(.invalidData))
            case .failure:
                commpletion(.failure(.connectivity))
            }
        }
    }
}
