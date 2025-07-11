//
//  EssentialFeediOS
//
//  Created by Mykola Dementiev
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: NSObject, UITableViewDataSource {
    let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.date
        cell.userNameLabel.text = model.userName
        
        return cell
    }
}
