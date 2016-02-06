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
        return data?.count ?? 0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?[section].members?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupMemberCell", forIndexPath: indexPath)
        if let zoneGroupMember = data?[indexPath.section].members?[indexPath.row] {
            //logger.info(zoneGroup.id)
            cell.textLabel?.text = "\(zoneGroupMember.zoneName.unescapeXml())"
        } else {
            cell.textLabel?.text = "ruh-roh"
        }
        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data?[section].id
    }
}
