//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public struct ImageComment: Equatable {
    public let id: UUID
    public let message: String
    public let createdAt: Date
    public let authorName: String
    
    public init(id: UUID, message: String, createdAt: Date, authorName: String) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.authorName = authorName
    }
}
