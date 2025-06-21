//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import Foundation

public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Equatable {
    public let message: String
    public let date: String
    public let userName: String
    
    public init(
        message: String,
        date: String,
        userName: String
    ) {
        self.message = message
        self.date = date
        self.userName = userName
    }
}

extension ImageCommentViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(message)
        hasher.combine(date)
        hasher.combine(userName)
    }
}

public final class ImageCommentsPresenter {
    
    public static var title: String {
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for the Image Comments View")
    }
    
    public static func map(
        _ comments: [ImageComment],
        currentDate: Date = Date(),
        calendar: Calendar = .current,
        locale: Locale = .current
    ) -> ImageCommentsViewModel {
        
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        
        return ImageCommentsViewModel(
            comments: comments
                .map { imageComment in
                    ImageCommentViewModel(
                        message: imageComment.message,
                        date: formatter.localizedString(for: imageComment.createdAt, relativeTo: currentDate),
                        userName: imageComment.userName
                    )
                })
    }
}
