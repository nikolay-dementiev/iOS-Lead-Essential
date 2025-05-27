//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

final class ImageCommentsMapper {
    
    static func map(_ data: Data,
                             from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        
        guard isOk(response),
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    private static func isOk(_ respons: HTTPURLResponse) -> Bool {
        200...299 ~= respons.statusCode
    }
}
