//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public final class FeedImageDataMapper {
    
    public enum Error: Swift.Error {
        case invalidData

    }
    
    public static func map(_ data: Data,
                           from response: HTTPURLResponse) throws -> Data {
        
        guard response.isOK else {
            throw Error.invalidData
        }
        
        let isValidResponse = response.isOK && !data.isEmpty
        
        return data
    }
}
