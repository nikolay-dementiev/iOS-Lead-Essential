//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

internal final class FeedItemsMapper {
    private static var OK_200 = 200
    
    internal static func map(_ data: Data,
                             from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
}
