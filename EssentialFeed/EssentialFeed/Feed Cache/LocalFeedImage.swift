//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public struct LocalFeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID,
                description: String? = nil,
                location: String? = nil,
                url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
