//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public final class FeedItemsMapper {
    
    private struct Root: Decodable {
        private struct RemoteFeedItem: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }

        private let items: [RemoteFeedItem]
        
        var images: [FeedImage] {
            items.map { FeedImage(id: $0.id,
                                  description: $0.description,
                                  location: $0.location,
                                  url: $0.image) }
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data,
                           from response: HTTPURLResponse) throws -> [FeedImage] {
        
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        
        return root.images
    }
}
