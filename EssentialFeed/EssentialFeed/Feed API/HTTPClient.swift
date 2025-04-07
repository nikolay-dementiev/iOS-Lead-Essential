//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    /// The completion block can be invoked on any thread.
    /// Client is responsible for dispatching to appropriate thread if needed.
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
