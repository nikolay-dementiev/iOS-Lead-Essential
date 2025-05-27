//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    /// The completion block can be invoked on any thread.
    /// Client is responsible for dispatching to appropriate thread if needed.
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
