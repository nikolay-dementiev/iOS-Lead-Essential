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
            feedLoader: makeRemotfeedLoaderWithFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: showComments(for:)
        ))
    private lazy var baseUrl: URL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: localStoreURL)
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var remoteFeedLoader: Publishers.TryMap<AnyPublisher<(Data, HTTPURLResponse), any Error>, [FeedImage]> = {
        let remoteURL = baseUrl.appendingPathComponent("/v1/feed")
        
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = remoteClient.getPublisher(url: remoteURL).tryMap(FeedItemsMapper.map)
        
        return remoteFeedLoader
    }()
    
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
        let remoteURL = baseUrl.appendingPathComponent("/v1/image/\(image.id)/comments")
        
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
    
    private func makeRemotfeedLoaderWithFallback() -> AnyPublisher<[FeedImage], Error> {
        return remoteFeedLoader
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
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
