//
//  ZoneGroupDataSource.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-30.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger
class ZoneGroupDataSource:NSObject, UITableViewDataSource {
    var data:[String]?

    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        logger.info(data?[indexPath.row])
        cell.textLabel?.text = data?[indexPath.row]
        return cell
    }

}
