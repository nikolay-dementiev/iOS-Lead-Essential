//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentationError: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            let task = session.dataTask(with: url) { data, response, error in
            completion( Result {
                if let error {
                    throw error
                } else if let data = data,
                            let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentationError()
                }
            })
        }
        
        task.resume()
        
        return URLSessionTaskWrapper(wrapped: task)
    }
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
}
