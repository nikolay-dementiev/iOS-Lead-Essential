//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import UIKit

public struct CellController {
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(
        dataSource: UITableViewDataSource,
        delegate: UITableViewDelegate? = nil,
        dataSourcePrefetching: UITableViewDataSourcePrefetching? = nil
    ) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.dataSourcePrefetching = dataSourcePrefetching
    }
    
    public init(
        _
        dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching
    ) {
        self.init(
            dataSource: dataSource,
            delegate: dataSource,
            dataSourcePrefetching: dataSource
        )
    }
}
