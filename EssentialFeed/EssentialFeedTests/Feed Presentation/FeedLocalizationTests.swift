//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {

	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        assertLocalisedKeysAndValuesExist(in: Bundle(for: FeedPresenter.self), "Feed")
	}
    
}
