//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public final class ImageCommentsMapper {
    private struct Root: Decodable {
        private let items: [Item]
        
        private struct Item: Decodable {
            let id: UUID
            let message: String
            let created_at: Date
            let author: Author
        }
        
        private struct Author: Decodable {
            let username: String
        }
        
        var comments: [ImageComment] {
            items.map {
                ImageComment(id: $0.id,
                             message: $0.message,
                             createdAt: $0.created_at,
                             userName: $0.author.username)
            }
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data,
                           from response: HTTPURLResponse) throws -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard isOk(response),
              let root = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        
        return root.comments
    }
    
    private static func isOk(_ respons: HTTPURLResponse) -> Bool {
        200...299 ~= respons.statusCode
    }
}
