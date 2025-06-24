//
//  EssentialApp
//
//  Created by Mykola Dementiev
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class CommentsUIComposer {
    
    private init() {}
    
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
    
    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {
        let presentationAdapter = CommentsPresentationAdapter(loader: { commentsLoader().dispatchOnMainQueue() })
        let commentController = makeCommentViewController(title: ImageCommentsPresenter.title)
        commentController.onRefresh = presentationAdapter.loadResource
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: CommentsViewAdapter(controller: commentController),
            loadingView: WeakRefVirtualProxy(commentController),
            errorView: WeakRefVirtualProxy(commentController),
            mapper: { ImageCommentsPresenter.map($0) }
        )
        
        return commentController
    }

    private static func makeCommentViewController(title: String) -> ListViewController {
        let storyboard = UIStoryboard(name: "ImageComments", bundle: Bundle(for: ListViewController.self))
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.title = title
        
        return controller
    }
}


final class CommentsViewAdapter: ResourceView {
    
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(
            viewModel.comments.map { model in
                CellController(
                    id: model,
                    dataSource: ImageCommentCellController(model: model)
                )
            })
    }
}
