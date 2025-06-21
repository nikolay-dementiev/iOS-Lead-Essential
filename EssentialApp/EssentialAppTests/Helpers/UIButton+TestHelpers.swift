//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import UIKit
import EssentialFeediOS

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}

extension ErrorView {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
