//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import Foundation

public final class RemoteImageCommentsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = Swift.Result<[ImageComment], Swift.Error>
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL,
                client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(Self.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data,
                            from response: HTTPURLResponse) -> Result {
        do {
            let items = try ImageCommentsMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
