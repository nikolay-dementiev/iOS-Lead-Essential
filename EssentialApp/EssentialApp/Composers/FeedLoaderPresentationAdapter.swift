//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    
    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoading(with: feed)
                })
    }
}
