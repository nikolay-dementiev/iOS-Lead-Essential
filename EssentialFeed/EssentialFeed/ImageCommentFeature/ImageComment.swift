//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public struct ImageComment: Equatable {
    public let id: UUID
    public let message: String
    public let createdAt: Date
    public let userName: String
    
    public init(id: UUID, message: String, createdAt: Date, userName: String) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.userName = userName
    }
}
