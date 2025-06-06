//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        location != nil
    }
}
