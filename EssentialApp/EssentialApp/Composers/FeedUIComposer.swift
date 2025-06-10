//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//


import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class FeedUIComposer {
    
    private init() {}
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    
    public static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: { feedLoader().dispatchOnMainQueue() })
        let feedController = makeFeedViewController(delegate: presentationAdapter,
                                                         title: FeedPresenter.title)
        presentationAdapter.presenter = LoadResourcePresenter(resourceView: FeedViewAdapter(controller: feedController,
                                                                                            imageLoader: imageLoader),
                                                              loadingView: WeakRefVirtualProxy(feedController),
                                                              errorView: WeakRefVirtualProxy(feedController),
                                                              mapper: FeedPresenter.map)
        
        return feedController
    }

    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> ListViewController {
        let storyboard = UIStoryboard(name: "Feed", bundle: Bundle(for: ListViewController.self))
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.delegate = delegate
        feedController.title = FeedPresenter.title
        
        return feedController
    }
}
