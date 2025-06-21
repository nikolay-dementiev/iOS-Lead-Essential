//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import UIKit

public struct CellController {
    let id: AnyHashable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(
        id: AnyHashable,
        dataSource: UITableViewDataSource,
        delegate: UITableViewDelegate? = nil,
        dataSourcePrefetching: UITableViewDataSourcePrefetching? = nil
    ) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = delegate
        self.dataSourcePrefetching = dataSourcePrefetching
    }
    
    public init(
        id: AnyHashable,
        _ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching
    ) {
        self.init(
            id: id,
            dataSource: dataSource,
            delegate: dataSource,
            dataSourcePrefetching: dataSource
        )
    }
}

extension CellController: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
    
