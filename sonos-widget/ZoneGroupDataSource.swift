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
    var data:[ZoneGroup]?

    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if let zoneGroup = data?[indexPath.row] {
            logger.info(zoneGroup.id)
            cell.textLabel?.text = "\(zoneGroup.id) (\(zoneGroup.members!.count) members)"
        } else {
            cell.textLabel?.text = "ruh-roh"
        }
        return cell
    }

}
