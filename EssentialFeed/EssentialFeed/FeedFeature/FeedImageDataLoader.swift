//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
