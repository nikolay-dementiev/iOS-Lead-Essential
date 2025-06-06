//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        assertLocalisedKeysAndValuesExist(in: Bundle(for: LoadResourcePresenter<Any, DummyView>.self), "Shared")
    }
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
