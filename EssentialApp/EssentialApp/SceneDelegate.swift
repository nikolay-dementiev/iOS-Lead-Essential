//
//  EssentialApp
//
//  Created by Mykola Dementiev
//

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
        try! CoreDataFeedStore(storeURL: localStoreURL)
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
//    private lazy var remoteFeedLoader: Publishers.TryMap<AnyPublisher<(Data, HTTPURLResponse), any Error>, [FeedImage]> = {
//        let remoteURL = FeedEndpoint.get().url(baseURL: baseURL)
//        
//        let remoteFeedLoader = makeRemoteClient()
//            .getPublisher(url: remoteURL)
//            .tryMap(FeedItemsMapper.map)
//        
//        return remoteFeedLoader
//    }()
//    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
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
        localFeedLoader.validateCache { _ in }
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
        let remoteURL = FeedEndpoint.get().url(baseURL: baseURL)
        
        return makeRemoteClient()
            .getPublisher(url: remoteURL)
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map { items in
                Paginated(
                    items: items,
                    loadMorePublisher: self.makeRemoteLoadMoreLoader(
                        items: items,
                        last: items.last
                    )
                )
            }
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(items: [FeedImage], last: FeedImage?) -> (() -> AnyPublisher<Paginated<FeedImage>, Error>)? {
        
        last.map { lastItem in
            let remoteURL = FeedEndpoint.get(after: lastItem).url(baseURL: baseURL)
            
            return { [self] in
                self.makeRemoteClient()
                    .getPublisher(url: remoteURL)
                    .tryMap(FeedItemsMapper.map)
                    .map { [weak self, items] newitems in
                        let paginatedItems = items + newitems
                        return Paginated(
                            items: paginatedItems,
                            loadMorePublisher: self?.makeRemoteLoadMoreLoader(
                                items: paginatedItems,
                                last: newitems.last
                            )
                        )
                    }.eraseToAnyPublisher()
            }
        }
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
//        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let remoteImageLoader = httpClient
            .getPublisher(url: url)
            .tryMap(FeedImageDataMapper.map)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteImageLoader
//                    .loadImageDataPublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            })
    }
}

//REMOVE:extension RemoteLoader: @retroactive FeedLoader where Resource == [FeedImage] {}
