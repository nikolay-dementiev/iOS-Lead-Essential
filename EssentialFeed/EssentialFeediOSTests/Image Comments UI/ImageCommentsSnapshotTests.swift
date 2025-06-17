//
//  EssentialFeediOSTests
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import EssentialFeed
import EssentialFeediOS

final class ImageCommentsSnapshotTests: XCTestCase {

    func test_listWithComments() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
    }

    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        //        controller.simulateAppearance()
        
        return controller
    }
    
    private func comments() -> [CellController] {
        commentControllers().map {
            CellController(
                dataSource: $0 as UITableViewDataSource,
                delegate: $0 as? UITableViewDelegate,
                dataSourcePrefetching: $0 as? UITableViewDataSourcePrefetching
            )
        }
    }
    
    private func commentControllers() -> [ImageCommentCellController] {
        return [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    userName: "a long long long long long username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    userName: "a long username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "short",
                    date: "1 hour ago",
                    userName: "a."
                )
            )
        ]
    }
}
