//
//  TodayViewDataSource.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-02-22.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger
import sonosclient

class TodayViewDataSource:NSObject, UITableViewDataSource {
    var data:[ZoneGroup]?
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.data?.count) ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        logger.info("tablecell for \(indexPath)")
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if let groupName = data?[indexPath.row].groupCoordinator {
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.text = "\(groupName.unescapeXml())"
        }
        return cell
    }

}