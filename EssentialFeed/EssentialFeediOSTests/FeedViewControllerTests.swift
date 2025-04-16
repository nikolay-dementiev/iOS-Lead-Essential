//
//  EssentialFeediOSTests
//
//  Created by Mykola Dementiev
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var onViewIsAppearing: ((FeedViewController) -> Void)?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = CustomUIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        self.onViewIsAppearing =  { vc in
            vc.load()
            
            vc.onViewIsAppearing = nil
        }
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeededWithAppearanceTransition()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_userInitiatedFeedReload_reloadsFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeededWithAppearanceTransition()
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeededWithAppearanceTransition()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeededWithAppearanceTransition()
        loader.completeFeedLoading()
        
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_pullToRefresh_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading()
        
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeacks(loader, file: file, line: line)
        trackForMemoryLeacks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading() {
            completions[0](.success([]))
        }
    }
}

private final class CustomUIRefreshControl: UIRefreshControl {
    private var _isRefreshing: Bool = false
    
    override var isRefreshing: Bool {
        _isRefreshing
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()
        
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        
        _isRefreshing = false
    }
}

private extension FeedViewController {
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension FeedViewController {
    func loadViewIfNeededWithAppearanceTransition() {
        super.loadViewIfNeeded()
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
}
