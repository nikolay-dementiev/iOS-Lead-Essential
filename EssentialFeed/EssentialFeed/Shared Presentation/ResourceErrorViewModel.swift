//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public struct ResourceErrorViewModel {
    public let message: String?
    
    static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> Self {
        ResourceErrorViewModel(message: message)
    }
}
