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
    
    public static func feedComposedWith(feedLoader: @escaping () -> FeedLoader.Publisher, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdaper(feedLoader: { feedLoader().dispatchOnMainQueue() })
        let feedController = makeFeedViewController(delegate: presentationAdapter,
                                                         title: FeedPresenter.title)
        presentationAdapter.presenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedController,
                                                                                imageLoader: imageLoader),
                                                      loadingView: WeakRefVirtualProxy(feedController),
                                                      errorView: WeakRefVirtualProxy(feedController))
        
        return feedController
    }

    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let storyboard = UIStoryboard(name: "Feed", bundle: Bundle(for: FeedViewController.self))
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = FeedPresenter.title
        
        return feedController
    }
}
