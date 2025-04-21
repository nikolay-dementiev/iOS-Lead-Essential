//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
