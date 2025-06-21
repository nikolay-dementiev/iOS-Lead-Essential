//
//  EssentialFeediOS
//
//  Created by Mykola Dementiev
//

import UIKit

public final class ImageCommentCell: UITableViewCell {
    @IBOutlet private(set) public var messageLabel: UILabel!
    @IBOutlet private(set) public var userNameLabel: UILabel!
    @IBOutlet private(set) public var dateLabel: UILabel!
    
    var onReuse: (() -> Void)?
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        onReuse?()
    }
}
