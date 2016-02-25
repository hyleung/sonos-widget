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
        let cell = tableView.dequeueReusableCellWithIdentifier("SonosGroupCell", forIndexPath: indexPath) as! SonosGroupCell
        if let members = data?[indexPath.row].members {
            cell.backgroundColor = UIColor.clearColor()
            let title = members.map({ (member) -> String in
                member.zoneName.unescapeXml()
            }).joinWithSeparator(", ")
            
            cell.label.text = title
        }
        return cell
    }

}