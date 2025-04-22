//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import UIKit

final class FeedRefreshViewController: NSObject {
    lazy var view: UIRefreshControl = binded(CustomUIRefreshControl())
    
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl  {
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
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
