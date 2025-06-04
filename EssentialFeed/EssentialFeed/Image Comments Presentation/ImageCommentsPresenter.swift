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

public final class ImageCommentsPresenter {
    
    public static var title: String {
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for the Image Comments View")
    }
    
    public static func map(_ comments: [ImageComment]) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        
        return ImageCommentsViewModel(
            comments: comments
                .map { imageComment in
                    ImageCommentViewModel(
                        message: imageComment.message,
                        date: formatter.localizedString(for: imageComment.createdAt, relativeTo: Date()),
                        userName: imageComment.userName
                    )
                })
    }
}
