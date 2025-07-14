//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed

final class ImageCommentsPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    func test_map_createViewModel() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        let comments = [
            ImageComment(
                id: UUID(uuidString: "35C725E7-8C6B-48D3-977A-1A4CDC29BB85")!,
                message: "a message",
                createdAt: now.adding(minutes: -60, calendar: calendar),
                userName: "a user name"
            ),
            ImageComment(
                id: UUID(uuidString: "A1D2A7CC-1E71-45D8-BE77-00210A7BB5E1")!,
                message: "another message",
                createdAt: now.adding(days: -14, calendar: calendar),
                userName: "another user name"
            )
        ]

        let viewModel = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale
        )

        XCTAssertEqual(
            viewModel.comments,
            [
                ImageCommentViewModel(
                    message: "a message",
                    date: "1 hour ago",
                    userName: "a user name"
                ),
                ImageCommentViewModel(
                    message: "another message",
                    date: "2 weeks ago",
                    userName: "another user name"
                )
            ]
        )
    }
    
    func test_map_createsViewModels() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        
        let comments = [
            ImageComment(
                id: UUID(),
                message: "a message",
                createdAt: now.adding(minutes: -5, calendar: calendar),
                userName: "a user name"
            ),
            ImageComment(
                id: UUID(),
                message: "another message",
                createdAt: now.adding(days: -1, calendar: calendar),
                userName: "another user name"
            )
        ]
        
        let viewModel = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale
        )
        
        XCTAssertEqual(
            viewModel.comments,
            [
                ImageCommentViewModel(
                    message: "a message",
                    date: "5 minutes ago",
                    userName: "a user name"
                ),
                ImageCommentViewModel(
                    message: "another message",
                    date: "1 day ago",
                    userName: "another user name"
                )
            ]
        )
    }
    
    // MARK: - Helpers
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table: String = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
}
