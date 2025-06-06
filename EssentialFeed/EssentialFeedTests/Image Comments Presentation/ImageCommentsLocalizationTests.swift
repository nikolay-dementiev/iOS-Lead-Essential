//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        assertLocalisedKeysAndValuesExist(in: Bundle(for: ImageCommentsPresenter.self), "ImageComments")
    }
}
