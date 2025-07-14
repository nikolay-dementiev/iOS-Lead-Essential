//
//  EssentialApp
//
//  Created by Mykola Dementiev
//

import os
import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")
    
    private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "infra.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: showComments(for:)
        ))
    private lazy var baseURL: URL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(storeURL: localStoreURL)
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var logger = Logger(
        subsystem: "com.essentialdeveloper.EssentialAppCaseStudy",
        category: "main"
    )
    
    convenience init(
        httpClient: HTTPClient,
        store: FeedStore & FeedImageDataStore,
        scheduler: AnyDispatchQueueScheduler
    ) {
        self.init()
        self.httpClient = httpClient
        self.store = store
        self.scheduler = scheduler
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func makeRemoteClient() -> HTTPClient {
        httpClient
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        scheduler.schedule { [localFeedLoader, logger] in
            do {
                try localFeedLoader.validateCache()
            } catch {
                logger.error("Failed to validate cache with error: \(error.localizedDescription)")
            }
        }
    }
    
    private func showComments(for image: FeedImage) {
        let remoteURL = baseURL.appendingPathComponent("/v1/image/\(image.id)/comments")
        
        let comments = CommentsUIComposer.commentsComposedWith(
            commentsLoader: makeRemoteCommentsLoader(for: remoteURL)
        )
        
        navigationController.pushViewController(comments, animated: true)
    }
    
    private func makeRemoteCommentsLoader(for url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        { [httpClient] in
            httpClient
                .getPublisher(url: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        makeRemoteFeedLoader()
            .receive(on: scheduler)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
//            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
        
        makeRemoteFeedLoader(after: last)
            .zip(localFeedLoader.loadPublisher())
            .map { (newItems, cachedItem) in
                (cachedItem + newItems, newItems.last)
            }
            .map(makePage)
            .receive(on: scheduler)
         /*
            .delay(for: 2, scheduler: DispatchQueue.main)
            .flatMap { _ in
                Fail(error: NSError())
            }
         */
            .caching(to: localFeedLoader)
//            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
        
        let remoteURL = FeedEndpoint.get(after: after).url(baseURL: baseURL)
        
        return self.makeRemoteClient()
            .getPublisher(url: remoteURL)
            .tryMap(FeedItemsMapper.map)
            .eraseToAnyPublisher()
    }
    
    private func makePage(items: [FeedImage], last: FeedImage? = nil) -> Paginated<FeedImage> {
        Paginated(
            items: items,
            loadMorePublisher: last.map { last in { self.makeRemoteLoadMoreLoader(last: last) }
            }
        )
    }
    
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        //        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        
        let client = httpClient
        /*
         let client = HTTPClientProfilingDecorator(
         decoratee: httpClient,
         logger: logger
         )
         */
        
        let remoteImageLoader = client
            .getPublisher(url: url)
            .tryMap(FeedImageDataMapper.map)
            .receive(on: scheduler)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteImageLoader
                //                    .loadImageDataPublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            })
        //            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}

//REMOVE:extension RemoteLoader: @retroactive FeedLoader where Resource == [FeedImage] {}


private class HTTPClientProfilingDecorator: HTTPClient {
    private let decoratee: HTTPClient
    private let logger: Logger
    
    init(decoratee: HTTPClient,
         logger: Logger) {
        self.decoratee = decoratee
        self.logger = logger
    }
    
    func get(
        from url: URL,
        completion: @escaping (HTTPClient.Result) -> Void
    ) -> any EssentialFeed.HTTPClientTask {
        logger.trace("Started loading url: \(url)")
        
        let startTime = CACurrentMediaTime()
        return decoratee.get(from: url, completion: { [logger] result in
            if case let .failure(error) = result {
                logger.trace("Failed to load url: \(url): \(error.localizedDescription)")
            }
            let elapsedTime = CACurrentMediaTime() - startTime
            logger.trace("Finished loading url: \(url) in \(elapsedTime) seconds")
            
            completion(result)
        })
    }
}
