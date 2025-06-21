//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    init(controller: ListViewController,
         imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(
            viewModel.feed
                .map { model in
                    //REMOVE
                    //let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
                    
                    let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                        imageLoader(model.url)
                    })
                    
                    let view = FeedImageCellController(
                        viewModel: FeedImagePresenter.map(model),
                        delegate: adapter
                    )
                    
                    adapter.presenter = LoadResourcePresenter<Data, WeakRefVirtualProxy>(
                        resourceView: WeakRefVirtualProxy(view),
                        loadingView: WeakRefVirtualProxy(view),
                        errorView: WeakRefVirtualProxy(view),
                        mapper: UIImage.tryMake(data:))
                    
                    return CellController(
                        id: model,
                        dataSource: view,
                        delegate: view,
                        dataSourcePrefetching: view
                    )
                })
    }
}

private extension UIImage {
    struct InvalidImageData: Error {}

    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}
